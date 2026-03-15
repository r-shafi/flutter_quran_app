import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';

class GeometricPatternPainter extends CustomPainter {
  const GeometricPatternPainter({
    required this.opacity,
    required this.rotationTurns,
  });

  final double opacity;
  final double rotationTurns;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColorValues.transparent;

    final step = size.width / 8;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationTurns * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);

    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        _drawEightPointStar(canvas, paint, Offset(x, y), step * 0.32);
      }
    }

    canvas.restore();
  }

  void _drawEightPointStar(Canvas canvas, Paint paint, Offset c, double r) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final point = Offset(
        c.dx + math.cos(angle) * r,
        c.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GeometricPatternPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.rotationTurns != rotationTurns;
  }
}

class GeometricPatternLayer extends StatelessWidget {
  const GeometricPatternLayer({
    super.key,
    this.opacity = 0.06,
    this.rotationTurns = 0,
  });

  final double opacity;
  final double rotationTurns;

  @override
  Widget build(BuildContext context) {
    final patternColor =
        context.palette.goldMuted.withValues(alpha: opacity.clamp(0, 1));

    return CustomPaint(
      painter: _TintedGeometricPatternPainter(
        base: GeometricPatternPainter(
          opacity: opacity,
          rotationTurns: rotationTurns,
        ),
        color: patternColor,
      ),
      size: Size.infinite,
    );
  }
}

class _TintedGeometricPatternPainter extends CustomPainter {
  const _TintedGeometricPatternPainter({
    required this.base,
    required this.color,
  });

  final GeometricPatternPainter base;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;

    final step = size.width / 8;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(base.rotationTurns * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);

    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path();
        final r = step * 0.32;
        for (int i = 0; i < 8; i++) {
          final angle = (math.pi / 4) * i;
          final point = Offset(
            x + math.cos(angle) * r,
            y + math.sin(angle) * r,
          );
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TintedGeometricPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.base.rotationTurns != base.rotationTurns;
  }
}
