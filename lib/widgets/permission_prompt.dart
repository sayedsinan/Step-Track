import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionPrompt extends StatelessWidget {
  final WidgetRef ref;

  const PermissionPrompt({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.health_and_safety, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Permissions Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Please grant Health Connect permissions\nor enable simulation mode',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/permissions'),
            icon: const Icon(Icons.lock_open),
            label: const Text('Grant Permissions'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/debug'),
            icon: const Icon(Icons.bug_report),
            label: const Text('Enable Simulation'),
          ),
        ],
      ),
    );
  }
}

