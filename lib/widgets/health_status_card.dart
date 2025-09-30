import 'package:flutter/material.dart';
import 'package:step_track/widgets/stat_row.dart';

class HealthStatusCard extends StatelessWidget {
  final healthState;

  const HealthStatusCard({super.key, required this.healthState});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StatRow(label: 'Permissions', value: healthState.hasAllPermissions ? 'Granted' : 'Not Granted', icon: Icons.lock_open,
                color: healthState.hasAllPermissions ? Colors.green : Colors.orange),
            const SizedBox(height: 8),
            StatRow(label: 'Polling', value: healthState.isPolling ? 'Active' : 'Inactive', icon: Icons.sync,
                color: healthState.isPolling ? Colors.green : Colors.grey),
            const SizedBox(height: 8),
            StatRow(label: 'Step Records', value: healthState.stepRecords.length.toString(), icon: Icons.directions_walk),
            const SizedBox(height: 8),
            StatRow(label: 'HR Records', value: healthState.hrRecords.length.toString(), icon: Icons.favorite),
            const SizedBox(height: 8),
            StatRow(label: 'Today Steps', value: healthState.todaySteps.toString(), icon: Icons.trending_up),
            if (healthState.lastHR != null) ...[
              const SizedBox(height: 8),
              StatRow(label: 'Last HR', value: '${healthState.lastHR!.bpm} BPM', icon: Icons.monitor_heart),
            ],
          ],
        ),
      ),
    );
  }
}

