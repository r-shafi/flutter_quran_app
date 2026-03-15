import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';

class GoldIconButton extends StatelessWidget {
  const GoldIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = AppSizes.iconButton,
    this.iconSize,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double? iconSize;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColorValues.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: context.palette.bgElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.shadowCard,
            border: isActive
                ? Border.all(color: context.palette.goldPrimary)
                : null,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: isActive
                ? context.palette.goldPrimary
                : context.palette.textMuted,
          ),
        ),
      ),
    );
  }
}
