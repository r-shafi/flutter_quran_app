import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';

class GoldBadge extends StatelessWidget {
  const GoldBadge({
    super.key,
    required this.label,
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final horizontal = compact ? AppSpacing.sm : AppSpacing.md;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.palette.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.palette.goldPrimary),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: context.palette.goldPrimary,
        ),
      ),
    );
  }
}
