import 'package:flutter/material.dart';

class DebugInfoBox extends StatelessWidget {
  const DebugInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Debug Information', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          Text('• Simulation mode generates synthetic data every 3 seconds', style: TextStyle(color: Colors.blue)),
          SizedBox(height: 4),
          Text('• Health Connect polling occurs every 5 seconds when active', style: TextStyle(color: Colors.blue)),
          SizedBox(height: 4),
          Text('• Data is kept for last 60 minutes in memory', style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}

