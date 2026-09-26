import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GasGauge extends StatelessWidget {
  final double level; // 0.0 to 100.0
  final double size;
  final double capacity;

  const GasGauge({
    super.key,
    required this.level,
    this.capacity = 12.5,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final remainingKg = (level / 100 * capacity).toStringAsFixed(1);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom Painter for the Arc
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              level: level,
              primaryColor: level < 20 ? AppTheme.criticalRed : AppTheme.accentTeal,
              secondaryColor: AppTheme.accentBlue,
            ),
          ),
          
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${level.toInt()}%',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$remainingKg KG',
                style: TextStyle(
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accentTeal,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'REMAINING',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: size * 0.04,
                  color: Colors.white24,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double level;
  final Color primaryColor;
  final Color secondaryColor;

  _GaugePainter({
    required this.level,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 10;
    const startAngle = 0.75 * math.pi;
    const totalSweep = 1.5 * math.pi;
    final progressSweep = totalSweep * (level / 100);

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      bgPaint,
    );

    // Progress Arc with Gradient
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [primaryColor, secondaryColor],
        startAngle: startAngle,
        endAngle: startAngle + totalSweep,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Use a separate arc to apply the sweep gradient correctly to the path
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // Glow Effect
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
