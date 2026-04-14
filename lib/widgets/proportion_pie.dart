import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../theme/app_theme.dart';

/// A small pie-slice graphic showing elapsed proportion.
/// Diameter scales with [settings.fontSizeScale].
class ProportionPie extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final AppSettings settings;

  const ProportionPie({
    super.key,
    required this.progress,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final deviceScale = MediaQuery.of(context).textScaler.scale(1);
    final size = 28.0 * settings.fontSizeScale * deviceScale;
    final fill = AppTheme.barFillColor(settings);
    final track = AppTheme.trackColor(settings);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PiePainter(
          progress: progress.clamp(0.0, 1.0),
          fillColor: fill,
          trackColor: track,
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final double progress;
  final Color fillColor;
  final Color trackColor;

  const _PiePainter({
    required this.progress,
    required this.fillColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final trackPaint = Paint()..color = trackColor;
    final fillPaint = Paint()..color = fillColor;

    // Full circle track.
    canvas.drawOval(rect, trackPaint);

    // Filled slice (sweep from top, clockwise).
    if (progress > 0) {
      const startAngle = -math.pi / 2; // 12 o'clock
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(rect, startAngle, sweepAngle, true, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.progress != progress ||
      old.fillColor != fillColor ||
      old.trackColor != trackColor;
}
