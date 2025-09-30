import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/providers/sim_provider.dart';

class SimulationBanner extends StatelessWidget {
  final WidgetRef ref;

  const SimulationBanner({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.orange),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Simulation Mode Active',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(simProviderInstance.notifier).disable(),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }
}
