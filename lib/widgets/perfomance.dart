import 'package:flutter/material.dart';
import 'dart:async';

class PerformanceHUD extends StatefulWidget {
  const PerformanceHUD({super.key});

  @override
  State<PerformanceHUD> createState() => _PerformanceHUDState();
}

class _PerformanceHUDState extends State<PerformanceHUD> {
  final List<Duration> _buildTimes = [];
  Duration _lastPaintTime = Duration.zero;
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();
  double _fps = 60.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          final elapsed = now.difference(_lastFrameTime).inMilliseconds;
          if (elapsed > 0) {
            _fps = (_frameCount * 1000 / elapsed).clamp(0, 60);
          }
          _frameCount = 0;
          _lastFrameTime = now;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void recordBuildTime(Duration duration) {
    _buildTimes.add(duration);
    if (_buildTimes.length > 100) {
      _buildTimes.removeAt(0);
    }
    _frameCount++;
  }

  void recordPaintTime(Duration duration) {
    _lastPaintTime = duration;
  }

  double get avgBuildTime {
    if (_buildTimes.isEmpty) return 0;
    final sum = _buildTimes.fold<int>(0, (s, d) => s + d.inMicroseconds);
    return sum / _buildTimes.length / 1000; // Convert to ms
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Avg Build: ${avgBuildTime.toStringAsFixed(2)}ms',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Last Paint: ${(_lastPaintTime.inMicroseconds / 1000).toStringAsFixed(2)}ms',
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'FPS: ${_fps.toStringAsFixed(1)}',
              style: TextStyle(
                color: _fps >= 55 ? Colors.greenAccent : Colors.redAccent,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Global key to access HUD from anywhere
final performanceHUDKey = GlobalKey<_PerformanceHUDState>();