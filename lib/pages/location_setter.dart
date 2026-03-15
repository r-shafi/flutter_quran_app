import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/gold_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSetter extends StatefulWidget {
  const LocationSetter({super.key});

  @override
  State<LocationSetter> createState() => _LocationSetterState();
}

class _LocationSetterState extends State<LocationSetter> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefs.then((prefs) {
      _cityController.text = prefs.getString('city') ?? '';
      _countryController.text = prefs.getString('country') ?? '';
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_cityController.text.isEmpty || _countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter city and country')),
      );
      return;
    }

    final prefs = await _prefs;
    await prefs.setString('city', _cityController.text);
    await prefs.setString('country', _countryController.text);
    if (!mounted) return;
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: context.palette.textMuted),
      filled: true,
      fillColor: context.palette.bgElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.palette.goldMuted),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.palette.goldMuted),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.palette.goldPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const LuxAppBar(
        title: Text('Location'),
        showBack: true,
      ),
      body: ScreenBackground(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              const SectionHeader(title: 'Location'),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _cityController,
                      decoration: _inputDecoration(context, 'City'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _countryController,
                      decoration: _inputDecoration(context, 'Country'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'If your city is unavailable, choose the nearest one.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GoldButton(label: 'Set Location', onPressed: _save),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
