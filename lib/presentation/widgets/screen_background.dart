import 'package:flutter/material.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/presentation/widgets/geometric_pattern_painter.dart';

class ScreenBackground extends StatelessWidget {
  const ScreenBackground({
    super.key,
    required this.child,
    this.showPattern = false,
    this.patternOpacity = 0.05,
    this.patternTurns = 0,
  });

  final Widget child;
  final bool showPattern;
  final double patternOpacity;
  final double patternTurns;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: context.palette.bgDeep),
        if (showPattern)
          GeometricPatternLayer(
            opacity: patternOpacity,
            rotationTurns: patternTurns,
          ),
        child,
      ],
    );
  }
}
