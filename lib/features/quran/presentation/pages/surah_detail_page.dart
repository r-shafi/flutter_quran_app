import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_error_widget.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';

class SurahDetailPage extends StatelessWidget {
  final Surah surah;

  const SurahDetailPage({
    Key? key,
    required this.surah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuranBloc>()..add(LoadSurahContentEvent(surah.number)),
      child: SurahDetailView(surah: surah),
    );
  }
}

class SurahDetailView extends StatefulWidget {
  final Surah surah;

  const SurahDetailView({
    Key? key,
    required this.surah,
  }) : super(key: key);

  @override
  State<SurahDetailView> createState() => _SurahDetailViewState();
}

class _SurahDetailViewState extends State<SurahDetailView> {
  final player = AudioPlayer();
  int? currentPlayingAyah;
  bool isPlaying = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void playAyah(String audioUrl, int ayahNumber) async {
    if (currentPlayingAyah == ayahNumber && isPlaying) {
      await player.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      await player.setUrl(audioUrl);
      await player.play();
      setState(() {
        currentPlayingAyah = ayahNumber;
        isPlaying = true;
      });

      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            isPlaying = false;
            currentPlayingAyah = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.englishName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement verse search
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              // TODO: Implement bookmark
            },
          ),
        ],
      ),
      body: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const AppLoadingIndicator(message: 'Loading verses...');
          }

          if (state is QuranError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<QuranBloc>().add(LoadSurahContentEvent(widget.surah.number));
              },
            );
          }

          if (state is SurahContentLoaded) {
            return Column(
              children: [
                // Surah Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppSpacing.lg),
                      bottomRight: Radius.circular(AppSpacing.lg),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.surah.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.surah.englishNameTranslation,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _InfoChip(
                            label: widget.surah.revelationType,
                            theme: theme,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _InfoChip(
                            label: '${widget.surah.numberOfAyahs} Verses',
                            theme: theme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bismillah (except for Surah 9)
                if (widget.surah.number != 9 && widget.surah.number != 1)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.arabicLarge,
                    ),
                  ),

                // Verses List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    itemCount: state.ayahs.length,
                    itemBuilder: (context, index) {
                      final ayah = state.ayahs[index];
                      return _buildAyahCard(context, ayah, theme);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAyahCard(BuildContext context, Ayah ayah, ThemeData theme) {
    final isCurrentlyPlaying = currentPlayingAyah == ayah.numberInSurah && isPlaying;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: () => playAyah(ayah.audio, ayah.numberInSurah),
        onLongPress: () {
          _showAyahOptions(context, ayah);
        },
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ayah number and controls
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isCurrentlyPlaying
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isCurrentlyPlaying
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => playAyah(ayah.audio, ayah.numberInSurah),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_outline,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Bookmark ayah
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Share ayah
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Arabic text
              Text(
                ayah.text,
                textAlign: TextAlign.right,
                style: AppTextStyles.arabicMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 2.0,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Translation placeholder
              Text(
                'Translation will be added here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAyahOptions(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmark'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Bookmark ayah
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share ayah
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Copy ayah
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Tafsir'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show tafsir
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _InfoChip({
    Key? key,
    required this.label,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
