import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/widgets/all_permission_granted.dart';
import 'package:step_track/widgets/error_display.dart';
import 'package:step_track/widgets/info_item.dart';
import 'package:step_track/widgets/permission_card.dart';
import 'package:step_track/widgets/request_permission_button.dart';
import '../providers/health_provider.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProviderInstance);

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
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
          PermissionCard(
            icon: Icons.directions_walk,
            title: 'Steps',
            description: 'Read your step count data',
            status: healthState.stepsPermission,
          ),
          const SizedBox(height: 16),
          PermissionCard(
            icon: Icons.favorite,
            title: 'Heart Rate',
            description: 'Read your heart rate data',
            status: healthState.hrPermission,
          ),
          const SizedBox(height: 24),
          if (!healthState.hasAllPermissions)
            RequestPermissionsButton(
              isLoading: healthState.isLoading,
              onPressed: () => ref.read(healthProviderInstance.notifier).requestPermissions(),
            ),
          if (healthState.hasAllPermissions) const AllPermissionsGranted(),
          if (healthState.error != null) ErrorDisplay(errorMessage: healthState.error!,onRetry: (){},),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'About Permissions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const InfoItem(icon: Icons.security, text: 'Your data never leaves your device'),
          const SizedBox(height: 8),
          const InfoItem(icon: Icons.visibility_off, text: 'No data is shared with third parties'),
          const SizedBox(height: 8),
          const InfoItem(icon: Icons.delete, text: 'You can revoke permissions anytime in system settings'),
        ],
      ),
    );
  }
}






