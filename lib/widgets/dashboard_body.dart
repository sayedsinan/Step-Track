
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/providers/health_provider.dart';
import 'package:step_track/providers/sim_provider.dart';
import 'package:step_track/widgets/error_display.dart';
import 'package:step_track/widgets/hr_card.dart';
import 'package:step_track/widgets/hr_chart.dart';
import 'package:step_track/widgets/permission_prompt.dart';
import 'package:step_track/widgets/simulation_banner.dart';
import 'package:step_track/widgets/step_card.dart';
import 'package:step_track/widgets/steps_chart.dart';

class DashboardBody extends StatelessWidget {
  final HealthState healthState;
  final SimState simState;
  final WidgetRef ref;

  const DashboardBody({
    super.key,
    required this.healthState,
    required this.simState,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    if (!healthState.hasAllPermissions && !simState.isEnabled) {
      return PermissionPrompt(ref: ref);
    }

    if (healthState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (healthState.error != null) {
      return ErrorDisplay(
        errorMessage: healthState.error!,
        onRetry: () => ref.read(healthProviderInstance.notifier).checkPermissions(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (healthState.hasAllPermissions) {
          await ref.read(healthProviderInstance.notifier).startPolling();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (simState.isEnabled) SimulationBanner(ref: ref),
            if (simState.isEnabled) const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: StepCard(/*steps: healthState.todaySteps, subtitle: healthState.isPolling ? 'Live' : 'Today'*/)),
                const SizedBox(width: 16),
                Expanded(child: HRCard(lastHR: healthState.lastHR)),
              ],
            ),
            const SizedBox(height: 16),
            StepsChart(records: healthState.stepRecords, windowMinutes: 60),
            const SizedBox(height: 16),
            HRChart(records: healthState.hrRecords, enableSmoothing: false),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}



