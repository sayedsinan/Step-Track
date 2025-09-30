import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/step_record.dart';
import '../models/hr_record.dart';

final healthNotifierProvider = StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  return HealthNotifier();
});

class HealthState {
  final bool stepsGranted;
  final bool hrGranted;
  final List<StepRecord> steps;
  final List<HRRecord> heartRates;

  HealthState({
    this.stepsGranted = false,
    this.hrGranted = false,
    this.steps = const [],
    this.heartRates = const [],
  });

  HealthState copyWith({
    bool? stepsGranted,
    bool? hrGranted,
    List<StepRecord>? steps,
    List<HRRecord>? heartRates,
  }) {
    return HealthState(
      stepsGranted: stepsGranted ?? this.stepsGranted,
      hrGranted: hrGranted ?? this.hrGranted,
      steps: steps ?? this.steps,
      heartRates: heartRates ?? this.heartRates,
    );
  }
}

class HealthNotifier extends StateNotifier<HealthState> {
  static const EventChannel _eventChannel = EventChannel('health_connect_events');
  StreamSubscription? _subscription;

  HealthNotifier() : super(HealthState()) {
    _startListening();
  }

  Future<void> requestPermissions() async {
    // Use flutter_health_connect plugin to request permissions
    // Placeholder: simulate permission granted
    state = state.copyWith(stepsGranted: true, hrGranted: true);
  }

  void _startListening() {
    _subscription = _eventChannel.receiveBroadcastStream().listen((event) {
      final Map map = event as Map;
      if (map['type'] == 'step') {
        final step = StepRecord(ts: map['ts'], count: map['count']);
        state = state.copyWith(steps: [...state.steps, step]);
      } else if (map['type'] == 'hr') {
        final hr = HRRecord(ts: map['ts'], bpm: map['bpm']);
        state = state.copyWith(heartRates: [...state.heartRates, hr]);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
