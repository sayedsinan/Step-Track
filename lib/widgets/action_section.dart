import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/providers/health_provider.dart';

class ActionsSection extends StatelessWidget {
  final healthState;
  final WidgetRef ref;

  const ActionsSection({super.key, required this.healthState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => ref.read(healthProviderInstance.notifier).checkPermissions(),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Permissions'),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: healthState.hasAllPermissions
              ? () => healthState.isPolling
                  ? ref.read(healthProviderInstance.notifier).stopPolling()
                  : ref.read(healthProviderInstance.notifier).startPolling()
              : null,
          icon: Icon(healthState.isPolling ? Icons.stop : Icons.play_arrow),
          label: Text(healthState.isPolling ? 'Stop Polling' : 'Start Polling'),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }
}

