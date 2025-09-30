import 'package:flutter/material.dart';
import '../providers/health_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthProvider = ref.watch(healthNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Steps Permission: ${healthProvider.stepsGranted ? "Granted" : "Denied"}'),
            Text('HR Permission: ${healthProvider.hrGranted ? "Granted" : "Denied"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ref.read(healthNotifierProvider.notifier).requestPermissions();
                if (healthProvider.stepsGranted && healthProvider.hrGranted) {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  // );
                }
              },
              child: const Text('Request Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
