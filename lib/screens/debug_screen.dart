import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sim_provider.dart';
import '../providers/health_provider.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simState = ref.watch(simProviderInstance);
    final healthState = ref.watch(healthProviderInstance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug & Simulation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Simulation Mode',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enable synthetic data generation for testing without Health Connect.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        simState.isEnabled ? Icons.play_circle : Icons.stop_circle,
                        color: simState.isEnabled ? Colors.green : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Simulation Source',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              simState.isEnabled ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: simState.isEnabled ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: simState.isEnabled,
                        onChanged: (value) {
                          ref.read(simProviderInstance.notifier).toggle();
                        },
                      ),
                    ],
                  ),
                  if (simState.isEnabled) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Step Records',
                      simState.stepRecords.length.toString(),
                      Icons.directions_walk,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'HR Records',
                      simState.hrRecords.length.toString(),
                      Icons.favorite,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(simProviderInstance.notifier).reset();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Data'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Health Connect Status',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(
                    'Permissions',
                    healthState.hasAllPermissions ? 'Granted' : 'Not Granted',
                    Icons.lock_open,
                    color: healthState.hasAllPermissions ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    'Polling',
                    healthState.isPolling ? 'Active' : 'Inactive',
                    Icons.sync,
                    color: healthState.isPolling ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    'Step Records',
                    healthState.stepRecords.length.toString(),
                    Icons.directions_walk,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    'HR Records',
                    healthState.hrRecords.length.toString(),
                    Icons.favorite,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    'Today Steps',
                    healthState.todaySteps.toString(),
                    Icons.trending_up,
                  ),
                  if (healthState.lastHR != null) ...[
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'Last HR',
                      '${healthState.lastHR!.bpm} BPM',
                      Icons.monitor_heart,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Actions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(healthProviderInstance.notifier).checkPermissions();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Permissions'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: healthState.hasAllPermissions
                ? () {
                    if (healthState.isPolling) {
                      ref.read(healthProviderInstance.notifier).stopPolling();
                    } else {
                      ref.read(healthProviderInstance.notifier).startPolling();
                    }
                  }
                : null,
            icon: Icon(healthState.isPolling ? Icons.stop : Icons.play_arrow),
            label: Text(healthState.isPolling ? 'Stop Polling' : 'Start Polling'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Debug Information',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Simulation mode generates synthetic data every 3 seconds',
                  style: TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Health Connect polling occurs every 5 seconds when active',
                  style: TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Data is kept for last 60 minutes in memory',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}