import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';

class GoldButton extends StatefulWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.pressScale,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: context.palette.goldPrimary,
              foregroundColor: context.palette.bgDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            onPressed: widget.onPressed == null
                ? null
                : () {
                    _controller.forward(from: 0);
                    widget.onPressed?.call();
                  },
            child: Text(
              widget.label,
              style:
                  textTheme.labelLarge?.copyWith(color: context.palette.bgDeep),
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: (1 - _controller.value) * 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      gradient: LinearGradient(
                        begin: Alignment(-1 + (_controller.value * 2), 0),
                        end: Alignment(-0.5 + (_controller.value * 2), 0),
                        colors: [
                          AppColorValues.transparent,
                          context.palette.textPrimary.withValues(alpha: 0.5),
                          AppColorValues.transparent,
                        ],
                      ),
                    ),
                    height: AppSpacing.xxl,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OutlineGoldButton extends StatelessWidget {
  const OutlineGoldButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: context.palette.goldPrimary,
          side: BorderSide(color: context.palette.goldPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: textTheme.labelLarge
              ?.copyWith(color: context.palette.goldPrimary),
        ),
      ),
    );
  }
}
