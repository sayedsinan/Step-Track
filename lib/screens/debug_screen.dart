import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/widgets/action_section.dart';
import 'package:step_track/widgets/debug_info.dart';
import 'package:step_track/widgets/health_status_card.dart';
import 'package:step_track/widgets/section_title.dart';
import 'package:step_track/widgets/simulation_card.dart';
import '../providers/sim_provider.dart';
import '../providers/health_provider.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simState = ref.watch(simProviderInstance);
    final healthState = ref.watch(healthProviderInstance);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug & Simulation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: 'Simulation Mode', description: 'Enable synthetic data generation for testing without Health Connect.'),
          const SizedBox(height: 24),
          SimulationCard(simState: simState, ref: ref),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Health Connect Status'),
          const SizedBox(height: 16),
          HealthStatusCard(healthState: healthState),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Actions'),
          const SizedBox(height: 16),
          ActionsSection(healthState: healthState, ref: ref),
          const SizedBox(height: 24),
          const DebugInfoBox(),
        ],
      ),
    );
  }
}

