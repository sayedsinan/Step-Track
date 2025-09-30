import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_track/utils/timestamp_util.dart';
import '../models/step_record.dart';
import '../models/hr_record.dart';

import 'sim_provider.dart';

final healthProviderInstance = StateNotifierProvider<HealthProvider, HealthState>((ref) {
  final provider = HealthProvider(ref);
  return provider;
});

enum PermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
}

class HealthState {
  final PermissionStatus stepsPermission;
  final PermissionStatus hrPermission;
  final List<StepRecord> stepRecords;
  final List<HRRecord> hrRecords;
  final int todaySteps;
  final HRRecord? lastHR;
  final bool isLoading;
  final String? error;
  final bool isPolling;

  HealthState({
    this.stepsPermission = PermissionStatus.unknown,
    this.hrPermission = PermissionStatus.unknown,
    this.stepRecords = const [],
    this.hrRecords = const [],
    this.todaySteps = 0,
    this.lastHR,
    this.isLoading = false,
    this.error,
    this.isPolling = false,
  });

  HealthState copyWith({
    PermissionStatus? stepsPermission,
    PermissionStatus? hrPermission,
    List<StepRecord>? stepRecords,
    List<HRRecord>? hrRecords,
    int? todaySteps,
    HRRecord? lastHR,
    bool? isLoading,
    String? error,
    bool? isPolling,
    bool clearLastHR = false,
  }) {
    return HealthState(
      stepsPermission: stepsPermission ?? this.stepsPermission,
      hrPermission: hrPermission ?? this.hrPermission,
      stepRecords: stepRecords ?? this.stepRecords,
      hrRecords: hrRecords ?? this.hrRecords,
      todaySteps: todaySteps ?? this.todaySteps,
      lastHR: clearLastHR ? null : (lastHR ?? this.lastHR),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isPolling: isPolling ?? this.isPolling,
    );
  }

  bool get hasAllPermissions =>
      stepsPermission == PermissionStatus.granted &&
      hrPermission == PermissionStatus.granted;
}

class HealthProvider extends StateNotifier<HealthState> {
  final Ref _ref;
  Health? _health;
  Timer? _pollingTimer;
  final Set<String> _processedIds = {};

  HealthProvider(this._ref) : super(HealthState()) {
    _initializeHealth();
    
    // Listen to sim provider
    _ref.listen<SimState>(simProviderInstance, (previous, next) {
      if (next.isEnabled) {
        // When sim is enabled, merge sim data
        _mergeSimData(next.stepRecords, next.hrRecords);
      }
    });
  }

  void _initializeHealth() {
    _health = Health();
  }

  Future<void> checkPermissions() async {
    state = state.copyWith(isLoading: true);

    try {
      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
      ];

      final permissions = await _health?.hasPermissions(types) ?? false;

      if (permissions) {
        state = state.copyWith(
          stepsPermission: PermissionStatus.granted,
          hrPermission: PermissionStatus.granted,
        );
      } else {
        // Check individual permissions
        final stepsGranted = await _health?.hasPermissions([HealthDataType.STEPS]) ?? false;
        final hrGranted = await _health?.hasPermissions([HealthDataType.HEART_RATE]) ?? false;

        state = state.copyWith(
          stepsPermission: stepsGranted ? PermissionStatus.granted : PermissionStatus.denied,
          hrPermission: hrGranted ? PermissionStatus.granted : PermissionStatus.denied,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to check permissions: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> requestPermissions() async {
    state = state.copyWith(isLoading: true);

    try {
      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
      ];

      final permissions = [
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ];

      final granted = await _health?.requestAuthorization(types, permissions: permissions) ?? false;

      if (granted) {
        state = state.copyWith(
          stepsPermission: PermissionStatus.granted,
          hrPermission: PermissionStatus.granted,
        );
        
        // Start polling after permissions granted
        startPolling();
      } else {
        state = state.copyWith(
          stepsPermission: PermissionStatus.denied,
          hrPermission: PermissionStatus.denied,
          error: 'Permissions denied',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to request permissions: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> startPolling() async {
    if (state.isPolling) return;

    state = state.copyWith(isPolling: true);

    // Initial fetch
    await _fetchHealthData();

    // Poll every 5 seconds
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchHealthData();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = state.copyWith(isPolling: false);
  }

  Future<void> _fetchHealthData() async {
    if (!state.hasAllPermissions) return;

    try {
      final now = DateTime.now();
      final startOfToday = TimestampUtils.startOfToday();
      final oneHourAgo = now.subtract(const Duration(hours: 1));

      // Fetch steps for today
      final stepsData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfToday,
        endTime: now,
      );

      // Fetch heart rate for last hour
      final hrData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: oneHourAgo,
        endTime: now,
      );

      _processHealthData(stepsData, hrData);
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch health data: $e');
    }
  }

  void _processHealthData(List<HealthDataPoint>? stepsData, List<HealthDataPoint>? hrData) {
    final newStepRecords = <StepRecord>[];
    final newHrRecords = <HRRecord>[];

    // Process steps
    if (stepsData != null) {
      int totalSteps = 0;
      for (var point in stepsData) {
        final id = '${point.type}_${point.dateFrom.millisecondsSinceEpoch}';
        
        if (!_processedIds.contains(id)) {
          _processedIds.add(id);
          
          final value = point.value;
          if (value is num) {
            totalSteps += (value as double).toInt();
            newStepRecords.add(StepRecord(
              timestamp: point.dateFrom,
              count: totalSteps,
              id: id,
            ));
          }
        }
      }
      
      if (newStepRecords.isNotEmpty) {
        state = state.copyWith(todaySteps: totalSteps);
      }
    }

    // Process heart rate
    if (hrData != null) {
      for (var point in hrData) {
        final id = '${point.type}_${point.dateFrom.millisecondsSinceEpoch}';
        
        if (!_processedIds.contains(id)) {
          _processedIds.add(id);
          
          final value = point.value;
          if (value is num) {
            newHrRecords.add(HRRecord(
              timestamp: point.dateFrom,
              bpm: (value is num ? (value as num).toInt() : 0),
              id: id,
            ));
          }
        }
      }
    }

    // Merge with existing records
    if (newStepRecords.isNotEmpty || newHrRecords.isNotEmpty) {
      final allStepRecords = [...state.stepRecords, ...newStepRecords];
      final allHrRecords = [...state.hrRecords, ...newHrRecords];

      // Sort by timestamp
      allStepRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      allHrRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Keep only last 60 minutes of data
      final cutoff = DateTime.now().subtract(const Duration(hours: 1));
      final filteredSteps = allStepRecords.where((r) => r.timestamp.isAfter(cutoff)).toList();
      final filteredHr = allHrRecords.where((r) => r.timestamp.isAfter(cutoff)).toList();

      state = state.copyWith(
        stepRecords: filteredSteps,
        hrRecords: filteredHr,
        lastHR: filteredHr.isNotEmpty ? filteredHr.last : null,
      );
    }

    // Clean up old processed IDs (keep only last 10000)
    if (_processedIds.length > 10000) {
      final idsToKeep = _processedIds.skip(_processedIds.length - 5000).toSet();
      _processedIds.clear();
      _processedIds.addAll(idsToKeep);
    }
  }

  void _mergeSimData(List<StepRecord> simSteps, List<HRRecord> simHr) {
    final allStepRecords = [...state.stepRecords, ...simSteps];
    final allHrRecords = [...state.hrRecords, ...simHr];

    // Remove duplicates and sort
    final uniqueSteps = allStepRecords.toSet().toList();
    final uniqueHr = allHrRecords.toSet().toList();

    uniqueSteps.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    uniqueHr.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate today's steps
    final startOfToday = TimestampUtils.startOfToday();
    final todaySteps = uniqueSteps
        .where((r) => r.timestamp.isAfter(startOfToday))
        .fold<int>(0, (sum, r) => sum + r.count);

    state = state.copyWith(
      stepRecords: uniqueSteps,
      hrRecords: uniqueHr,
      todaySteps: todaySteps,
      lastHR: uniqueHr.isNotEmpty ? uniqueHr.last : null,
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}