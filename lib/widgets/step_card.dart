// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/health_provider.dart';
// // Ensure healthNotifierProvider is exported from health_provider.dart


// class StepCard extends ConsumerWidget {
//   const StepCard({super.key, required int steps, required String subtitle});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final steps = ref.watch(healthNotifierProvider).steps;
//     final totalSteps = steps.fold<int>(0, (prev, e) => prev + e.count);

//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             const Icon(Icons.directions_walk, size: 40),
//             const SizedBox(width: 16),
//             Text('Steps Today: $totalSteps', style: const TextStyle(fontSize: 20)),
//           ],
//         ),
//       ),
//     );
//   }
// }
