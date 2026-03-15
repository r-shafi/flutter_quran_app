import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/arabic_text.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final Map<String, List<Map<String, String>>> _azkarData = {
    'Morning': [
      {
        'arabic': 'سُبْحَانَ اللهِ',
        'text': 'SubhanAllah',
        'count': '33',
      },
      {
        'arabic': 'الْحَمْدُ لِلّٰهِ',
        'text': 'Alhamdulillah',
        'count': '33',
      },
      {
        'arabic': 'اللّٰهُ أَكْبَرُ',
        'text': 'Allahu Akbar',
        'count': '34',
      },
    ],
    'Evening': [
      {
        'arabic': 'أَسْتَغْفِرُ اللهَ',
        'text': 'Astaghfirullah',
        'count': '100',
      },
      {
        'arabic': 'لَا إِلٰهَ إِلَّا اللهُ',
        'text': 'La ilaha illallah',
        'count': '10',
      },
    ],
  };

  final Map<String, int> _tapCount = {};
  String _selectedCategory = 'Morning';

  @override
  Widget build(BuildContext context) {
    final list = _azkarData[_selectedCategory] ?? [];
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const LuxAppBar(
        title: Text('Azkar'),
        showBack: true,
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const SectionHeader(title: 'Categories'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: _azkarData.keys.map((category) {
                final selected = _selectedCategory == category;
                return SizedBox(
                  width: AppSizes.quickTile,
                  height: AppSizes.quickTile,
                  child: PressableCard(
                    onTap: () => setState(() => _selectedCategory = category),
                    accentLeft: selected,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category == 'Morning' ? 'ذِكْر' : 'دُعَاء',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: ArabicSize.surahName,
                            color: context.palette.goldPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          category,
                          style: textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Zikr List'),
            const SizedBox(height: AppSpacing.md),
            ...list.map((item) {
              final key = '${_selectedCategory}_${item['text']}';
              final count = _tapCount[key] ?? 0;

              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ArabicText(item['arabic']!, fontSize: ArabicSize.minimum),
                    const SizedBox(height: AppSpacing.sm),
                    const GoldDivider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item['text']!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          'Repeat ${item['count']} times',
                          style: textTheme.labelSmall?.copyWith(
                            color: context.palette.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$count',
                          style: textTheme.titleMedium?.copyWith(
                            color: context.palette.goldPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GoldIconButton(
                          icon: Icons.add,
                          size: AppSizes.iconButtonSmall,
                          onTap: () {
                            setState(() {
                              _tapCount[key] = count + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
