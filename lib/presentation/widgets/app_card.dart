import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.accentLeft = false,
    this.backgroundColor,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool accentLeft;
  final Color? backgroundColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final basePadding = padding ?? const EdgeInsets.all(AppSpacing.md);
    final contentPadding = accentLeft
        ? basePadding.add(
            const EdgeInsets.only(left: AppSizes.cardAccentWidth),
          )
        : basePadding;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.palette.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: glow ? AppShadows.shadowGlow : AppShadows.shadowCard,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            if (accentLeft)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: AppSizes.cardAccentWidth,
                child: ColoredBox(
                  color: context.palette.goldPrimary,
                ),
              ),
            Padding(
              padding: contentPadding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class PressableCard extends StatefulWidget {
  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.accentLeft = false,
    this.backgroundColor,
    this.glow = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool accentLeft;
  final Color? backgroundColor;
  final bool glow;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppDurations.pressScale,
        child: AppCard(
          margin: widget.margin,
          padding: widget.padding,
          accentLeft: widget.accentLeft,
          backgroundColor: widget.backgroundColor,
          glow: widget.glow,
          child: widget.child,
        ),
      ),
    );
  }
}
