import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/di/injection_container.dart';
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuranError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<QuranBloc>()
                          .add(const LoadSurahListEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 8.0,
        right: 8.0,
      ),
      child: ListTile(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        tileColor: lastTrack == index
            ? Colors.blueGrey
            : Colors.black12.withOpacity(0.05),
        title: Text(
          surah.englishName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: lastTrack == index ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          surah.englishNameTranslation,
          style: TextStyle(
            color: lastTrack == index ? Colors.white70 : Colors.black54,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: lastTrack == index ? Colors.white : Colors.blueGrey,
          child: Text(
            '${surah.number}',
            style: TextStyle(
              color: lastTrack == index ? Colors.blueGrey : Colors.white,
            ),
          ),
        ),
        trailing: Text(
          surah.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: lastTrack == index ? Colors.white : Colors.black,
          ),
        ),
        onTap: () {
          context.read<QuranBloc>().add(LoadSurahContentEvent(surah.number));
        },
      ),
    );
  }
}
