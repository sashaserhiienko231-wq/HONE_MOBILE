import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class LatencyChart extends StatelessWidget {
  final List<double> pings;
  final double height;

  const LatencyChart({
    super.key,
    required this.pings,
    this.height = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: _LatencyLinePainter(
          pings: pings,
          strokeColor: AppTheme.neonPurple,
          fillColor: AppTheme.neonBlue,
        ),
      ),
    );
  }
}

class _LatencyLinePainter extends CustomPainter {
  final List<double> pings;
  final Color strokeColor;
  final Color fillColor;

  _LatencyLinePainter({
    required this.pings,
    required this.strokeColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pings.isEmpty) {
      _drawNoData(canvas, size);
      return;
    }

    final maxVal = pings.reduce((a, b) => a > b ? a : b);
    final minVal = pings.reduce((a, b) => a < b ? a : b);
    
    // Determine bounds
    double highest = maxVal > 60.0 ? maxVal + 10 : 80.0;
    double lowest = minVal < 10.0 ? 0.0 : minVal - 5;
    if (highest == lowest) highest += 10.0;

    final double range = highest - lowest;
    final double stepX = size.width / 24; // Limit to 25 history nodes

    // Draw Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    const int gridRows = 4;
    for (int i = 0; i <= gridRows; i++) {
      final double y = size.height * (i / gridRows);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      
      // Draw grid text label
      final textValue = highest - (range * (i / gridRows));
      final textSpan = TextSpan(
        text: '${textValue.toInt()}ms',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 8,
          fontFamily: 'Inter',
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(4, y - 10));
    }

    // Path construction
    final path = Path();
    final fillPath = Path();

    // Map ping index to UI x, y
    final int pointsCount = pings.length;
    final List<Offset> points = [];

    for (int i = 0; i < pointsCount; i++) {
      final double val = pings[i];
      final double x = size.width - ((pointsCount - 1 - i) * stepX);
      
      // Calculate normalized height (Y starts from top, so invert)
      final double normalizedY = (val - lowest) / range;
      final double y = size.height - (normalizedY * size.height);
      
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        // Curve to point for smooth aesthetic
        final prev = points[i - 1];
        final curr = points[i];
        final controlX = (prev.dx + curr.dx) / 2;
        
        path.cubicTo(controlX, prev.dy, controlX, curr.dy, curr.dx, curr.dy);
        fillPath.cubicTo(controlX, prev.dy, controlX, curr.dy, curr.dx, curr.dy);
      }

      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      // Draw Gradient Fill under line
      final fillPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          [
            strokeColor.withValues(alpha: 0.3),
            fillColor.withValues(alpha: 0.0),
          ],
        )
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // Draw Holographic Grid Glow Shadow
      final glowPaint = Paint()
        ..color = strokeColor.withValues(alpha: 0.15)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawPath(path, glowPaint);

      // Draw Neon Path Line
      final linePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);

      // Draw Glowing Dot on the current (last) ping node
      if (points.isNotEmpty) {
        final lastOffset = points.last;
        
        final dotGlowPaint = Paint()
          ..color = AppTheme.neonGreen.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
        canvas.drawCircle(lastOffset, 8.0, dotGlowPaint);

        final dotPaint = Paint()..color = AppTheme.neonGreen;
        canvas.drawCircle(lastOffset, 4.0, dotPaint);
      }
    }
  }

  void _drawNoData(ui.Canvas canvas, ui.Size size) {
    final textSpan = TextSpan(
      text: 'WAITING FOR PACKETS...',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.2),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        fontFamily: 'Inter',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    
    textPainter.paint(
      canvas,
      ui.Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _LatencyLinePainter oldDelegate) {
    return oldDelegate.pings != pings;
  }
}
