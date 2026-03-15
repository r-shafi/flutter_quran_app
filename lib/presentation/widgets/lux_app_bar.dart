import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';

class LuxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LuxAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.actions = const [],
  });

  final Widget title;
  final Widget? subtitle;
  final bool showBack;
  final List<Widget> actions;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (subtitle == null ? 0 : AppSpacing.md));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      centerTitle: true,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: GoldIconButton(
                icon: Icons.chevron_left,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            )
          : null,
      title: subtitle == null
          ? DefaultTextStyle(
              style: textTheme.titleLarge!
                  .copyWith(color: context.palette.textPrimary),
              child: title,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: textTheme.titleLarge!
                      .copyWith(color: context.palette.textPrimary),
                  child: title,
                ),
                const SizedBox(height: AppSpacing.xs),
                DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: ArabicSize.subtitle,
                    color: context.palette.goldPrimary,
                  ),
                  child: subtitle!,
                ),
              ],
            ),
      actions: actions
          .map(
            (action) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: action,
            ),
          )
          .toList(),
    );
  }
}
