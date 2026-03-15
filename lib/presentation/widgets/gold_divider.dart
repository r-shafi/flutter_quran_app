import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, this.opacity = 1});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.goldPrimary.withValues(alpha: opacity);

    return Container(
      height: AppSizes.dividerThickness,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorValues.transparent,
            color,
            AppColorValues.transparent,
          ],
        ),
      ),
    );
  }
}
