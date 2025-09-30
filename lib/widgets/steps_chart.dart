import 'package:flutter/material.dart';
import 'package:step_track/utils/timestamp_util.dart';
import 'package:step_track/widgets/perfomance.dart';
import 'dart:math' as math;
import '../models/step_record.dart';

class StepsChart extends StatefulWidget {
  final List<StepRecord> records;
  final int windowMinutes;

  const StepsChart({
    super.key,
    required this.records,
    this.windowMinutes = 60,
  });

  @override
  State<StepsChart> createState() => _StepsChartState();
}

class _StepsChartState extends State<StepsChart> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  Offset? _tooltipPosition;
  StepRecord? _tooltipRecord;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Steps (Last ${widget.windowMinutes} min)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            height: 250,
            child: GestureDetector(
              onScaleStart: (details) {
                _previousScale = _scale;
                _previousOffset = _offset;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_previousScale * details.scale).clamp(0.5, 5.0);
                  _offset = details.focalPoint - 
                      (details.focalPoint - _previousOffset) * details.scale;
                });
              },
              onTapDown: (details) {
                _handleTap(details.localPosition);
              },
              child: CustomPaint(
                painter: StepsChartPainter(
                  records: _getFilteredRecords(),
                  scale: _scale,
                  offset: _offset,
                  tooltipPosition: _tooltipPosition,
                  tooltipRecord: _tooltipRecord,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<StepRecord> _getFilteredRecords() {
    if (widget.records.isEmpty) return [];

    final now = DateTime.now();
    final cutoff = now.subtract(Duration(minutes: widget.windowMinutes));

    return widget.records.where((r) => r.timestamp.isAfter(cutoff)).toList();
  }

  void _handleTap(Offset position) {
    final records = _getFilteredRecords();
    if (records.isEmpty) return;

  
    setState(() {
      _tooltipPosition = position;
     
    });
  }
}

class StepsChartPainter extends CustomPainter {
  final List<StepRecord> records;
  final double scale;
  final Offset offset;
  final Offset? tooltipPosition;
  final StepRecord? tooltipRecord;

  static final _linePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  static final _pointPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;

  static final _gridPaint = Paint()
    ..color = Colors.grey.withOpacity(0.2)
    ..strokeWidth = 1;

  static final _tooltipPaint = Paint()
    ..color = Colors.black87;

  static final _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  StepsChartPainter({
    required this.records,
    required this.scale,
    required this.offset,
    this.tooltipPosition,
    this.tooltipRecord,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startTime = DateTime.now();

    if (records.isEmpty) {
      _drawNoData(canvas, size);
      _recordPaintTime(startTime);
      return;
    }

    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // Apply transformations
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // Draw grid
    _drawGrid(canvas, size, padding);

    // Find min/max for scaling
    final minSteps = 0;
    final maxSteps = records.map((r) => r.count).reduce(math.max);
    final stepRange = maxSteps - minSteps;

    if (stepRange == 0) {
      canvas.restore();
      _recordPaintTime(startTime);
      return;
    }

    final minTime = records.first.timestamp.millisecondsSinceEpoch;
    final maxTime = records.last.timestamp.millisecondsSinceEpoch;
    final timeRange = maxTime - minTime;

    if (timeRange == 0) {
      canvas.restore();
      _recordPaintTime(startTime);
      return;
    }


    final decimatedRecords = _decimateRecords(records, 500);


    final path = Path();
    bool firstPoint = true;

    for (var record in decimatedRecords) {
      final x = padding + 
          (record.timestamp.millisecondsSinceEpoch - minTime) / 
          timeRange * chartWidth * scale;
      final y = size.height - padding - 
          (record.count - minSteps) / stepRange * chartHeight;

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 3, _pointPaint);
    }

    canvas.drawPath(path, _linePaint);

    _drawAxes(canvas, size, padding, minSteps, maxSteps, minTime, maxTime);

    canvas.restore();

   
    if (tooltipPosition != null) {
      _drawTooltip(canvas, size, tooltipPosition!);
    }

    _recordPaintTime(startTime);
  }

  void _drawNoData(Canvas canvas, Size size) {
    _textPainter.text = const TextSpan(
      text: 'No data available',
      style: TextStyle(color: Colors.grey, fontSize: 16),
    );
    _textPainter.layout();
    _textPainter.paint(
      canvas,
      Offset(
        (size.width - _textPainter.width) / 2,
        (size.height - _textPainter.height) / 2,
      ),
    );
  }

  void _drawGrid(Canvas canvas, Size size, double padding) {
 
    for (int i = 0; i <= 5; i++) {
      final y = padding + (size.height - padding * 2) * i / 5;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        _gridPaint,
      );
    }


    for (int i = 0; i <= 5; i++) {
      final x = padding + (size.width - padding * 2) * i / 5;
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, size.height - padding),
        _gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, double padding, int minSteps, 
      int maxSteps, int minTime, int maxTime) {
  
    for (int i = 0; i <= 5; i++) {
      final value = minSteps + (maxSteps - minSteps) * i / 5;
      final y = size.height - padding - (size.height - padding * 2) * i / 5;

      _textPainter.text = TextSpan(
        text: value.toInt().toString(),
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      _textPainter.layout();
      _textPainter.paint(canvas, Offset(5, y - _textPainter.height / 2));
    }

    for (int i = 0; i <= 5; i++) {
      final time = DateTime.fromMillisecondsSinceEpoch(
        minTime + (maxTime - minTime) * i ~/ 5,
      );
      final x = padding + (size.width - padding * 2) * i / 5;

      _textPainter.text = TextSpan(
        text: TimestampUtils.formatTime(time),
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(x - _textPainter.width / 2, size.height - padding + 5),
      );
    }
  }

  void _drawTooltip(Canvas canvas, Size size, Offset position) {
    if (records.isEmpty) return;

    StepRecord? closest;
    double minDistance = double.infinity;

    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final minTime = records.first.timestamp.millisecondsSinceEpoch;
    final maxTime = records.last.timestamp.millisecondsSinceEpoch;
    final timeRange = maxTime - minTime;

    for (var record in records) {
      final x = padding + 
          (record.timestamp.millisecondsSinceEpoch - minTime) / 
          timeRange * chartWidth * scale;
      final distance = (x - position.dx).abs();

      if (distance < minDistance) {
        minDistance = distance;
        closest = record;
      }
    }

    if (closest == null) return;


    final text = '${closest.count} steps\n${TimestampUtils.formatTime(closest.timestamp)}';
    _textPainter.text = TextSpan(
      text: text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    );
    _textPainter.layout();

    final tooltipWidth = _textPainter.width + 16;
    final tooltipHeight = _textPainter.height + 16;
    final tooltipX = (position.dx + tooltipWidth > size.width)
        ? position.dx - tooltipWidth
        : position.dx;
    final tooltipY = (position.dy - tooltipHeight < 0)
        ? position.dy + 10
        : position.dy - tooltipHeight;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
      const Radius.circular(4),
    );

    canvas.drawRRect(rect, _tooltipPaint);
    _textPainter.paint(canvas, Offset(tooltipX + 8, tooltipY + 8));
  }

  List<StepRecord> _decimateRecords(List<StepRecord> records, int maxPoints) {
    if (records.length <= maxPoints) return records;

    final result = <StepRecord>[];
    final step = records.length / maxPoints;

    for (int i = 0; i < maxPoints; i++) {
      final index = (i * step).floor();
      if (index < records.length) {
        result.add(records[index]);
      }
    }

    return result;
  }

  void _recordPaintTime(DateTime startTime) {
    final paintTime = DateTime.now().difference(startTime);
    
    try {
      final hud = performanceHUDKey.currentState;
      hud?.recordPaintTime(paintTime);
    } catch (_) {
    
    }
  }

  @override
  bool shouldRepaint(StepsChartPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.tooltipPosition != tooltipPosition;
  }
}