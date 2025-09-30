import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_provider.dart';
// Ensure healthNotifierProvider is exported from health_provider.dart

class StepCard extends ConsumerWidget {
  const StepCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    final totalSteps = ref.watch(healthProviderInstance).todaySteps;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
        
            Text('Steps Today: $totalSteps', style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
