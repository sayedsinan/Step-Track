import 'package:flutter/material.dart';
import 'package:step_track/utils/timestamp_util.dart';
import '../models/hr_record.dart';

class HRCard extends StatelessWidget {
  final HRRecord? lastHR;

  const HRCard({
    super.key,
    this.lastHR,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heart Rate',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        lastHR != null
                            ? TimestampUtils.formatAge(lastHR!.timestamp)
                            : 'No data',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lastHR != null ? '${lastHR!.bpm}' : '--',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            if (lastHR != null)
              Text(
                'BPM',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}