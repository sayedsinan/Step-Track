import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/step_record.dart';
import '../models/hr_record.dart';

final simProviderInstance = StateNotifierProvider<SimProvider, SimState>((ref) {
  return SimProvider();
});

class SimState {
  final bool isEnabled;
  final List<StepRecord> stepRecords;
  final List<HRRecord> hrRecords;

  SimState({
    this.isEnabled = false,
    this.stepRecords = const [],
    this.hrRecords = const [],
  });

  SimState copyWith({
    bool? isEnabled,
    List<StepRecord>? stepRecords,
    List<HRRecord>? hrRecords,
  }) {
    return SimState(
      isEnabled: isEnabled ?? this.isEnabled,
      stepRecords: stepRecords ?? this.stepRecords,
      hrRecords: hrRecords ?? this.hrRecords,
    );
  }
}

class SimProvider extends StateNotifier<SimState> {
  Timer? _timer;
  final Random _random = Random();
  int _stepCounter = 0;
  int _hrBase = 70;

  SimProvider() : super(SimState());

  void toggle() {
    if (state.isEnabled) {
      disable();
    } else {
      enable();
    }
  }

  void enable() {
    state = state.copyWith(isEnabled: true);
    _startSimulation();
  }

  void disable() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isEnabled: false);
  }

  void _startSimulation() {
    _timer?.cancel();
    
    // Generate updates every 2-5 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!state.isEnabled) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      
      // Generate step update (incremental)
      _stepCounter += _random.nextInt(20) + 5;
      final stepRecord = StepRecord(
        timestamp: now,
        count: _stepCounter,
        id: 'sim_step_${now.millisecondsSinceEpoch}',
      );

      // Generate heart rate update (realistic variation)
      _hrBase = (_hrBase + _random.nextInt(10) - 5).clamp(60, 120);
      final hrRecord = HRRecord(
        timestamp: now,
        bpm: _hrBase + _random.nextInt(10) - 5,
        id: 'sim_hr_${now.millisecondsSinceEpoch}',
      );

      final newStepRecords = [...state.stepRecords, stepRecord];
      final newHrRecords = [...state.hrRecords, hrRecord];

      // Keep only last 1000 records to prevent memory issues
      if (newStepRecords.length > 1000) {
        newStepRecords.removeRange(0, newStepRecords.length - 1000);
      }
      if (newHrRecords.length > 1000) {
        newHrRecords.removeRange(0, newHrRecords.length - 1000);
      }

      state = state.copyWith(
        stepRecords: newStepRecords,
        hrRecords: newHrRecords,
      );
    });
  }

  void reset() {
    _stepCounter = 0;
    _hrBase = 70;
    state = state.copyWith(
      stepRecords: [],
      hrRecords: [],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}