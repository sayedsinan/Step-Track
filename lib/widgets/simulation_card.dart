
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/providers/sim_provider.dart';
import 'package:step_track/widgets/stat_row.dart';

class SimulationCard extends StatelessWidget {
  final simState;
  final WidgetRef ref;

  const SimulationCard({super.key, required this.simState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(simState.isEnabled ? Icons.play_circle : Icons.stop_circle,
                    color: simState.isEnabled ? Colors.green : Colors.grey, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Simulation Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(simState.isEnabled ? 'Active' : 'Inactive',
                          style: TextStyle(color: simState.isEnabled ? Colors.green : Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                  value: simState.isEnabled,
                  onChanged: (_) => ref.read(simProviderInstance.notifier).toggle(),
                ),
              ],
            ),
            if (simState.isEnabled) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              StatRow(label: 'Step Records', value: simState.stepRecords.length.toString(), icon: Icons.directions_walk),
              const SizedBox(height: 8),
              StatRow(label: 'HR Records', value: simState.hrRecords.length.toString(), icon: Icons.favorite),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.read(simProviderInstance.notifier).reset(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Data'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}