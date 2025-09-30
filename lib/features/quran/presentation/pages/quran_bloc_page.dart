import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_error_widget.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';

class QuranPageBloc extends StatelessWidget {
  const QuranPageBloc({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuranBloc>()..add(const LoadSurahListEvent()),
      child: const QuranView(),
    );
  }
}

class QuranView extends StatefulWidget {
  const QuranView({Key? key}) : super(key: key);

  @override
  State<QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<QuranView> {
  final player = AudioPlayer();
  int lastTrack = 0;
  bool isPlaying = false;
  List<Ayah>? currentAyahs;

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  void audioPlaybackController(int surah, List<Ayah> ayahs) async {
    if (player.playing && lastTrack == surah) {
      player.pause();
      setState(() {
        isPlaying = false;
      });
      return;
    }

    if (!player.playing && lastTrack == surah && currentAyahs != null) {
      player.play();
      setState(() {
        isPlaying = true;
      });
      return;
    }

    if (player.playing && lastTrack != surah) {
      player.stop();
      setState(() {
        isPlaying = false;
      });
    }

    setState(() {
      currentAyahs = ayahs;
    });

    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: ayahs
          .map((ayah) => AudioSource.uri(Uri.parse(ayah.audio)))
          .toList(),
    );

    await player.setAudioSource(playlist);

    setState(() {
      isPlaying = true;
      lastTrack = surah;
    });

    await player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isPlaying
          ? FloatingActionButton.extended(
              onPressed: () {
                if (player.playing) {
                  player.pause();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  player.play();
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              label: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (lastTrack > 1) {
                        context
                            .read<QuranBloc>()
                            .add(LoadSurahContentEvent(lastTrack - 1));
                      }
                    },
                    icon: const Icon(Icons.skip_previous_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      if (player.playing) {
                        player.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        player.play();
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
                    icon: Icon(
                      player.playing
                          ? Icons.pause_outlined
                          : Icons.play_arrow_outlined,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (lastTrack < 114) {
                        context
                            .read<QuranBloc>()
                            .add(LoadSurahContentEvent(lastTrack + 1));
                      }
                    },
                    icon: const Icon(Icons.skip_next_outlined),
                  ),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        title: const Text('Quran Audio'),
        centerTitle: true,
      ),
      body: BlocConsumer<QuranBloc, QuranState>(
        listener: (context, state) {
          if (state is SurahContentLoaded) {
            audioPlaybackController(state.surahNumber, state.ayahs);
          }
        },
        builder: (context, state) {
          if (state is QuranLoading) {
            return const AppLoadingIndicator(message: 'Loading Surahs...');
          }

          if (state is QuranError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<QuranBloc>().add(const LoadSurahListEvent());
              },
            );
          }

          if (state is SurahListLoaded) {
            return ListView.builder(
              itemCount: state.surahs.length,
              itemBuilder: (context, index) {
                final surah = state.surahs[index];
                return _buildSurahTile(context, surah, index + 1);
              },
            );
          }

          if (state is SurahContentLoaded) {
            // Still show the list but with current playing indication
            return BlocBuilder<QuranBloc, QuranState>(
              builder: (context, state) {
                if (state is SurahContentLoaded) {
                  // Reload the list
                  context.read<QuranBloc>().add(const LoadSurahListEvent());
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSurahTile(BuildContext context, Surah surah, int index) {
    final isPlaying = lastTrack == index;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Card(
        elevation: isPlaying ? 4 : 1,
        color: isPlaying
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMedium),
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPlaying
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${surah.number}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isPlaying
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            surah.englishName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPlaying
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            '${surah.englishNameTranslation} • ${surah.numberOfAyahs} verses',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isPlaying
                  ? theme.colorScheme.onPrimary.withOpacity(0.8)
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                surah.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPlaying
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? theme.colorScheme.onPrimary.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Text(
                  surah.revelationType,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPlaying
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            context.read<QuranBloc>().add(LoadSurahContentEvent(surah.number));
          },
        ),
      ),
    );
  }
}
