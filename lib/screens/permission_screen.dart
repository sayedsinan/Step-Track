import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_provider.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProviderInstance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Health Connect Permissions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This app requires access to your health data to display real-time information.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildPermissionCard(
            context,
            icon: Icons.directions_walk,
            title: 'Steps',
            description: 'Read your step count data',
            status: healthState.stepsPermission,
          ),
          const SizedBox(height: 16),
          _buildPermissionCard(
            context,
            icon: Icons.favorite,
            title: 'Heart Rate',
            description: 'Read your heart rate data',
            status: healthState.hrPermission,
          ),
          const SizedBox(height: 24),
          if (!healthState.hasAllPermissions)
            ElevatedButton.icon(
              onPressed: healthState.isLoading
                  ? null
                  : () {
                      ref.read(healthProviderInstance.notifier).requestPermissions();
                    },
              icon: healthState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_open),
              label: Text(healthState.isLoading ? 'Requesting...' : 'Request Permissions'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          if (healthState.hasAllPermissions)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'All permissions granted',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (healthState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Error',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          healthState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'About Permissions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.security,
            text: 'Your data never leaves your device',
          ),
          const SizedBox(height: 8),
          _buildInfoItem(
            icon: Icons.visibility_off,
            text: 'No data is shared with third parties',
          ),
          const SizedBox(height: 8),
          _buildInfoItem(
            icon: Icons.delete,
            text: 'You can revoke permissions anytime in system settings',
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required PermissionStatus status,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case PermissionStatus.granted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Granted';
        break;
      case PermissionStatus.denied:
        statusColor = Colors.orange;
        statusIcon = Icons.cancel;
        statusText = 'Denied';
        break;
      case PermissionStatus.permanentlyDenied:
        statusColor = Colors.red;
        statusIcon = Icons.block;
        statusText = 'Blocked';
        break;
      case PermissionStatus.unknown:
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Unknown';
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}