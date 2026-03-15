import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/pages/prayer_times.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';

class PrayerTime extends StatelessWidget {
  const PrayerTime({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const SectionHeader(title: 'Prayer Times'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(child: Text('Open detailed prayer schedule')),
              GoldIconButton(
                icon: Icons.arrow_forward_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrayerTimesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
