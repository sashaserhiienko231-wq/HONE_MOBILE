import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class JitterMeter extends StatelessWidget {
  final double jitter;
  final double packetLoss;
  final int score;

  const JitterMeter({
    super.key,
    required this.jitter,
    required this.packetLoss,
    required this.score,
  });

  Color _getScoreColor() {
    if (score >= 90) return AppTheme.neonGreen;
    if (score >= 70) return AppTheme.neonBlue;
    if (score >= 50) return AppTheme.neonOrange;
    return AppTheme.accentRed;
  }

  String _getStabilityText() {
    if (score >= 90) return 'EXCELLENT';
    if (score >= 75) return 'OPTIMAL';
    if (score >= 60) return 'MODERATE';
    return 'UNSTABLE';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getScoreColor();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating Ring background
              CustomPaint(
                size: const Size(120, 120),
                painter: _RadialGaugePainter(
                  score: score,
                  color: statusColor,
                ),
              ),
              // Score text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      height: 1,
                      shadows: [
                        Shadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'STABILITY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Stability status text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            _getStabilityText(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: statusColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Additional info grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatNode('Jitter', '${jitter.toStringAsFixed(1)} ms', statusColor),
            _buildStatNode('Packet Loss', '${(packetLoss * 100).toStringAsFixed(2)}%', statusColor),
          ],
        ),
      ],
    );
  }

  Widget _buildStatNode(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _RadialGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 8;

    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Draw full background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Angle conversions
    const startAngle = -pi / 2; // top center
    final sweepAngle = 2 * pi * (score / 100.0);

    // Draw active arc with glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
