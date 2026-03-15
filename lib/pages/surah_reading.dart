import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/main.dart';
import 'package:quran_app/models/surah_content.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/arabic_text.dart';
import 'package:quran_app/presentation/widgets/gold_badge.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingSurah {
  ReadingSurah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahs,
  });

  final int number;
  final String name;
  final String englishName;
  final List<ReadingAyah> ayahs;
}

class ReadingAyah {
  ReadingAyah({
    required this.numberInSurah,
    required this.arabicText,
    required this.number,
    this.translationText,
  });

  final int numberInSurah;
  final String arabicText;
  final String? translationText;
  final int number;
}

class SurahReadingScreen extends StatefulWidget {
  const SurahReadingScreen({
    super.key,
    this.surahNumber,
    this.juzNumber,
    required this.surahName,
    required this.englishName,
    this.initialAyahNumber,
  });

  final int? surahNumber;
  final int? juzNumber;
  final String surahName;
  final String englishName;
  final int? initialAyahNumber;

  @override
  State<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends State<SurahReadingScreen>
    with SingleTickerProviderStateMixin {
  bool _showTranslation = false;
  bool _autoScrollCurrentAyah = true;
  bool _showInlineAyahActions = false;

  ReadingSurah? _surahData;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _bookmarks = [];
  int _currentPlayingAyah = -1;
  int? _activeSurahInQueue;

  String _selectedVoice = 'Default Qari';
  bool _isPreparingPlayback = false;
  bool _isDownloadingSurah = false;
  double _downloadProgress = 0;

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  late final AnimationController _pulseController;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<MediaItem?>? _mediaItemSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.ayahPulse,
    )..repeat(reverse: true);
    _loadData();
    _watchAudioIndex();
  }

  @override
  void dispose() {
    _indexSub?.cancel();
    _mediaItemSub?.cancel();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadSurah(),
      _loadBookmarks(),
      _loadVoice(),
      _loadReadingPrefs(),
    ]);
  }

  void _watchAudioIndex() {
    _mediaItemSub = audioHandler.mediaItem.listen((item) {
      if (!mounted) return;

      final extras = item?.extras;
      final surahNumber = extras?['surahNumber'];

      setState(() {
        _activeSurahInQueue = surahNumber is int ? surahNumber : null;
      });
    });

    _indexSub = audioHandler.player.currentIndexStream.listen((index) {
      if (!mounted || index == null) return;

      if (!_isCurrentSurahInQueue) {
        if (_currentPlayingAyah != -1) {
          setState(() {
            _currentPlayingAyah = -1;
          });
        }
        return;
      }

      final ayahNumber = index + 1;
      setState(() {
        _currentPlayingAyah = ayahNumber;
      });
      _scrollCurrentAyahIntoView(ayahNumber);
    });
  }

  bool get _isCurrentSurahInQueue {
    if (widget.surahNumber == null) return false;
    return _activeSurahInQueue == widget.surahNumber;
  }

  Future<void> _loadReadingPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _showTranslation = prefs.getBool('reading_show_translation') ?? false;
      _autoScrollCurrentAyah = prefs.getBool('reading_auto_scroll') ?? true;
      _showInlineAyahActions =
          prefs.getBool('reading_show_inline_actions') ?? false;
    });
  }

  Future<void> _setReadingPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _loadVoice() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedVoice = prefs.getString('selectedVoice') ?? _selectedVoice;
    });
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('bookmarks');
    if (!mounted || value == null) return;
    setState(() {
      _bookmarks = List<Map<String, dynamic>>.from(jsonDecode(value));
    });
  }

  Future<void> _toggleBookmark(ReadingAyah ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final index = _bookmarks.indexWhere(
      (b) =>
          b['surahNumber'] == widget.surahNumber &&
          b['ayahNumber'] == ayah.numberInSurah,
    );

    if (index >= 0) {
      _bookmarks.removeAt(index);
    } else {
      _bookmarks.add({
        'surahNumber': widget.surahNumber,
        'ayahNumber': ayah.numberInSurah,
        'surahName': widget.surahName,
        'englishName': widget.englishName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString('bookmarks', jsonEncode(_bookmarks));
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _setLastRead(ReadingAyah ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReadSurah', widget.surahNumber ?? 1);
    await prefs.setInt('lastReadAyah', ayah.numberInSurah);
    await prefs.setString('lastReadSurahName', widget.englishName);
  }

  GlobalKey _ayahKeyFor(int ayahNumber) {
    return _ayahKeys.putIfAbsent(ayahNumber, GlobalKey.new);
  }

  void _scrollCurrentAyahIntoView(int ayahNumber) {
    if (!_autoScrollCurrentAyah) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayahKeys[ayahNumber];
      final contextForAyah = key?.currentContext;
      if (!mounted || contextForAyah == null) return;

      Scrollable.ensureVisible(
        contextForAyah,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.24,
      );
    });
  }

  Future<List<Ayah>> _fetchSurahAudioAyahs() async {
    if (widget.surahNumber == null) {
      return const [];
    }

    final prefs = await SharedPreferences.getInstance();
    final voice = prefs.getString('selectedVoice') ?? 'ar.ahmedajamy';

    final response = await http.get(
      Uri.parse(
          'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/$voice'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load surah audio');
    }

    final parsed = SurahContentModel.fromMap(jsonDecode(response.body));
    return parsed.data.ayahs;
  }

  Future<Directory> _surahAudioDirectory({required bool create}) async {
    if (widget.surahNumber == null) {
      throw Exception('Surah audio is only available for surah pages');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${appDir.path}/surah_audio/$_selectedVoice/surah_$widget.surahNumber',
    );

    if (create && !dir.existsSync()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  Future<File> _localAudioFileForAyah(int ayahNumber) async {
    final folder = await _surahAudioDirectory(create: true);
    return File('${folder.path}/$ayahNumber.mp3');
  }

  Future<void> _prepareAndPlaySurah({int startAtAyah = 1}) async {
    if (widget.surahNumber == null || _isPreparingPlayback) {
      return;
    }

    setState(() {
      _isPreparingPlayback = true;
    });

    try {
      final ayahs = await _fetchSurahAudioAyahs();
      if (ayahs.isEmpty) {
        throw Exception('No ayah audio found');
      }

      final queueItems = <MediaItem>[];
      final sources = <AudioSource>[];

      for (final ayah in ayahs) {
        final localFile = await _localAudioFileForAyah(ayah.numberInSurah);
        final hasLocal = await localFile.exists();

        final uri = hasLocal ? Uri.file(localFile.path) : Uri.parse(ayah.audio);

        queueItems.add(
          MediaItem(
            id: uri.toString(),
            album: widget.englishName,
            title: 'Ayah ${ayah.numberInSurah}',
            extras: {
              'surahNumber': widget.surahNumber,
              'ayahNumber': ayah.numberInSurah,
            },
          ),
        );

        sources.add(AudioSource.uri(uri));
      }

      final safeIndex = (startAtAyah - 1).clamp(0, ayahs.length - 1);

      await audioHandler.updateQueue(queueItems);
      await audioHandler.player.setAudioSources(
        sources,
        initialIndex: safeIndex,
        initialPosition: Duration.zero,
      );
      await audioHandler.play();

      if (!mounted) return;
      setState(() {
        _activeSurahInQueue = widget.surahNumber;
        _currentPlayingAyah = safeIndex + 1;
      });
      _scrollCurrentAyahIntoView(safeIndex + 1);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start playback: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPreparingPlayback = false;
        });
      }
    }
  }

  Future<void> _togglePlayback() async {
    final isPlayingNow = audioHandler.player.playing;

    if (_isCurrentSurahInQueue) {
      if (isPlayingNow) {
        await audioHandler.pause();
      } else {
        await audioHandler.play();
      }
      return;
    }

    await _prepareAndPlaySurah(
      startAtAyah: _currentPlayingAyah > 0 ? _currentPlayingAyah : 1,
    );
  }

  Future<void> _shareAyah(ReadingAyah ayah) async {
    final text = _showTranslation && ayah.translationText != null
        ? '${ayah.arabicText}\n\n${ayah.translationText}\n\n- Surah ${widget.englishName}, Ayah ${ayah.numberInSurah}'
        : '${ayah.arabicText}\n\n- Surah ${widget.englishName}, Ayah ${ayah.numberInSurah}';

    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _shareSurah() async {
    if (_surahData == null) return;

    await SharePlus.instance.share(
      ShareParams(text: '${_surahData!.englishName} - ${widget.surahName}'),
    );
  }

  Future<void> _downloadSurahAudio() async {
    if (widget.surahNumber == null || _isDownloadingSurah) {
      return;
    }

    setState(() {
      _isDownloadingSurah = true;
      _downloadProgress = 0;
    });

    try {
      final ayahs = await _fetchSurahAudioAyahs();
      if (ayahs.isEmpty) {
        throw Exception('No ayah audio available for download');
      }

      final folder = await _surahAudioDirectory(create: true);

      for (int i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        final file = File('${folder.path}/${ayah.numberInSurah}.mp3');

        if (!await file.exists()) {
          final response = await http.get(Uri.parse(ayah.audio));
          if (response.statusCode != 200) {
            throw Exception('Failed downloading ayah ${ayah.numberInSurah}');
          }
          await file.writeAsBytes(response.bodyBytes, flush: true);
        }

        if (!mounted) return;
        setState(() {
          _downloadProgress = (i + 1) / ayahs.length;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Surah audio downloaded for offline playback')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingSurah = false;
        });
      }
    }
  }

  Future<void> _showAyahActions(ReadingAyah ayah) async {
    final textTheme = Theme.of(context).textTheme;
    final isBookmarked = _bookmarks.any(
      (b) =>
          b['surahNumber'] == widget.surahNumber &&
          b['ayahNumber'] == ayah.numberInSurah,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSpacing.xl,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: context.palette.goldMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Ayah ${ayah.numberInSurah}',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: Icon(
                    isBookmarked
                        ? Icons.bookmark_remove_rounded
                        : Icons.bookmark_add_rounded,
                  ),
                  title:
                      Text(isBookmarked ? 'Remove bookmark' : 'Bookmark ayah'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _toggleBookmark(ayah);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Share ayah'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _shareAyah(ayah);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_rounded),
                  title: const Text('Mark as last read'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _setLastRead(ayah);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved as last read')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReadingOptions() async {
    final textTheme = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSpacing.xl,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: context.palette.goldMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reading options',
                    style: textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  value: _showTranslation,
                  activeThumbColor: context.palette.goldPrimary,
                  title: const Text('Show translation'),
                  subtitle: const Text('Applies to all ayahs in this screen'),
                  onChanged: (value) {
                    setState(() {
                      _showTranslation = value;
                    });
                    _setReadingPreference('reading_show_translation', value);
                  },
                ),
                SwitchListTile(
                  value: _autoScrollCurrentAyah,
                  activeThumbColor: context.palette.goldPrimary,
                  title: const Text('Auto-scroll current ayah'),
                  subtitle:
                      const Text('Keep active ayah in view while playing'),
                  onChanged: (value) {
                    setState(() {
                      _autoScrollCurrentAyah = value;
                    });
                    _setReadingPreference('reading_auto_scroll', value);
                  },
                ),
                SwitchListTile(
                  value: _showInlineAyahActions,
                  activeThumbColor: context.palette.goldPrimary,
                  title: const Text('Show quick actions on cards'),
                  subtitle:
                      const Text('Bookmark/share buttons on each ayah card'),
                  onChanged: (value) {
                    setState(() {
                      _showInlineAyahActions = value;
                    });
                    _setReadingPreference('reading_show_inline_actions', value);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.play_circle_rounded),
                  title: const Text('Play this surah'),
                  subtitle: const Text('Build queue and start from first ayah'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _prepareAndPlaySurah(startAtAyah: 1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Download full surah audio'),
                  subtitle: widget.surahNumber == null
                      ? const Text('Available for surah pages only')
                      : _isDownloadingSurah
                          ? Text(
                              'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%')
                          : const Text('Save for offline playback'),
                  onTap: widget.surahNumber == null || _isDownloadingSurah
                      ? null
                      : () {
                          Navigator.pop(sheetContext);
                          _downloadSurahAudio();
                        },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Share surah'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _shareSurah();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadSurah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isJuz = widget.juzNumber != null;
      final key = isJuz ? 'juz_reading_v2_' : 'surah_reading_v2_';

      String? cached;
      if (prefs.containsKey(key)) {
        cached = prefs.getString(key);
      }

      Map<String, dynamic> combinedData;
      if (cached != null) {
        combinedData = jsonDecode(cached);
      } else if (!isJuz) {
        final response = await http.get(
          Uri.parse(
            'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani,en.sahih',
          ),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to load Surah');
        }
        combinedData = jsonDecode(response.body);
      } else {
        final ar = await http.get(
          Uri.parse(
              'https://api.alquran.cloud/v1/juz/${widget.juzNumber}/quran-uthmani'),
        );
        final en = await http.get(
          Uri.parse(
              'https://api.alquran.cloud/v1/juz/${widget.juzNumber}/en.sahih'),
        );

        if (ar.statusCode != 200 || en.statusCode != 200) {
          throw Exception('Failed to load Juz');
        }

        combinedData = {
          'data': [jsonDecode(ar.body)['data'], jsonDecode(en.body)['data']],
        };
      }

      await prefs.setString(key, jsonEncode(combinedData));
      _parseAndSetData(combinedData, isJuz: isJuz);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _parseAndSetData(Map<String, dynamic> data, {required bool isJuz}) {
    final list = data['data'] as List;
    final arabicEdition =
        list.firstWhere((e) => e['edition']['identifier'] == 'quran-uthmani');
    final tlEdition = list.firstWhere(
      (e) => e['edition']['identifier'] == 'en.sahih',
      orElse: () => null,
    );

    final ayahs = <ReadingAyah>[];
    for (int i = 0; i < arabicEdition['ayahs'].length; i++) {
      final arAyah = arabicEdition['ayahs'][i];
      final tlAyah = tlEdition != null ? tlEdition['ayahs'][i] : null;
      ayahs.add(
        ReadingAyah(
          numberInSurah: arAyah['numberInSurah'],
          arabicText: arAyah['text'],
          translationText: tlAyah?['text'],
          number: arAyah['number'],
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _surahData = ReadingSurah(
        number: isJuz ? widget.juzNumber! : arabicEdition['number'],
        name: isJuz ? 'Juz' : arabicEdition['name'],
        englishName: widget.englishName,
        ayahs: ayahs,
      );
      _isLoading = false;
    });
  }

  Widget _ayahCard(ReadingAyah ayah) {
    final textTheme = Theme.of(context).textTheme;
    final isBookmarked = _bookmarks.any(
      (b) =>
          b['surahNumber'] == widget.surahNumber &&
          b['ayahNumber'] == ayah.numberInSurah,
    );

    final isPlaying = _currentPlayingAyah == ayah.numberInSurah;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulseOpacity = 0.5 + (_pulseController.value * 0.5);

        return KeyedSubtree(
          key: _ayahKeyFor(ayah.numberInSurah),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border(
                left: BorderSide(
                  color: isPlaying
                      ? context.palette.goldPrimary
                          .withValues(alpha: pulseOpacity)
                      : AppColorValues.transparent,
                  width: AppSizes.cardAccentWidth,
                ),
              ),
            ),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              backgroundColor: isPlaying
                  ? context.palette.bgElevated
                  : context.palette.bgSurface,
              child: InkWell(
                onTap: () async {
                  await _setLastRead(ayah);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Saved as last read')),
                  );
                },
                onLongPress: () => _showAyahActions(ayah),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (isBookmarked)
                          Icon(
                            Icons.bookmark_rounded,
                            size: AppSpacing.lg,
                            color: context.palette.goldPrimary,
                          ),
                        const Spacer(),
                        GoldBadge(label: ayah.numberInSurah.toString()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ArabicText(
                      ayah.arabicText,
                      fontSize: ArabicSize.ayah,
                    ),
                    if (_showTranslation && ayah.translationText != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const GoldDivider(opacity: 0.4),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        ayah.translationText!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: context.palette.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (_showInlineAyahActions)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GoldIconButton(
                            icon: isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: AppSizes.iconButtonSmall,
                            isActive: isBookmarked,
                            onTap: () => _toggleBookmark(ayah),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          GoldIconButton(
                            icon: Icons.share_rounded,
                            size: AppSizes.iconButtonSmall,
                            onTap: () => _shareAyah(ayah),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(Duration duration) {
    final mins = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$mins:$secs';
    }
    return '$mins:$secs';
  }

  Duration _totalQueueDuration(List<IndexedAudioSource> sequence) {
    var total = Duration.zero;
    for (final source in sequence) {
      total += source.duration ?? Duration.zero;
    }
    return total;
  }

  Duration _elapsedBeforeCurrentIndex(
    List<IndexedAudioSource> sequence,
    int currentIndex,
  ) {
    var elapsed = Duration.zero;
    for (int i = 0; i < currentIndex && i < sequence.length; i++) {
      elapsed += sequence[i].duration ?? Duration.zero;
    }
    return elapsed;
  }

  Future<void> _seekInSurahTimeline(Duration targetOffset) async {
    final sequence = audioHandler.player.sequence;
    if (sequence.isEmpty) return;

    var elapsed = Duration.zero;
    final clampedTarget =
        targetOffset.isNegative ? Duration.zero : targetOffset;

    for (int i = 0; i < sequence.length; i++) {
      final itemDuration = sequence[i].duration ?? Duration.zero;
      final isLast = i == sequence.length - 1;

      if (itemDuration == Duration.zero && !isLast) {
        continue;
      }

      final boundary = elapsed + itemDuration;
      if (clampedTarget <= boundary || isLast) {
        final localPosition = clampedTarget - elapsed;
        await audioHandler.player.seek(
          localPosition.isNegative ? Duration.zero : localPosition,
          index: i,
        );
        return;
      }

      elapsed = boundary;
    }
  }

  Widget _audioBar() {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.palette.bgElevated,
          border: Border(
            top: BorderSide(
              color: context.palette.goldMuted,
              width: AppSizes.dividerThickness,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isCurrentSurahInQueue
                        ? 'Now playing ${widget.englishName}'
                        : 'Ready to play ${widget.englishName}',
                    style: textTheme.titleSmall?.copyWith(
                      color: context.palette.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _selectedVoice,
                  style: textTheme.labelSmall?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
            StreamBuilder<Duration>(
              stream: audioHandler.player.positionStream,
              builder: (context, posSnapshot) {
                final position = posSnapshot.data ?? Duration.zero;
                final sequence = audioHandler.player.sequence;
                final currentIndex = audioHandler.player.currentIndex ?? 0;
                final currentDuration =
                    audioHandler.player.duration ?? Duration.zero;

                final totalDuration = _totalQueueDuration(sequence);
                final elapsedBefore =
                    _elapsedBeforeCurrentIndex(sequence, currentIndex);
                final surahPosition = elapsedBefore + position;
                final hasTimelineDuration = totalDuration > Duration.zero;

                final fallbackTotalAyahs =
                    (_surahData?.ayahs.length ?? sequence.length)
                        .clamp(1, 9999);
                final fallbackProgress = currentDuration.inMilliseconds <= 0
                    ? (currentIndex + 1).toDouble()
                    : (currentIndex +
                            (position.inMilliseconds /
                                currentDuration.inMilliseconds))
                        .clamp(0, fallbackTotalAyahs.toDouble())
                        .toDouble();

                final max = hasTimelineDuration
                    ? totalDuration.inMilliseconds.toDouble()
                    : fallbackTotalAyahs.toDouble();
                final value = hasTimelineDuration
                    ? surahPosition.inMilliseconds
                        .clamp(0, totalDuration.inMilliseconds)
                        .toDouble()
                    : fallbackProgress;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: context.palette.goldPrimary,
                        inactiveTrackColor: context.palette.bgSubtle,
                        thumbColor: context.palette.goldPrimary,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: AppSpacing.sm - AppSpacing.xs / 2,
                        ),
                      ),
                      child: Slider(
                        value: value,
                        max: max,
                        onChanged: !_isCurrentSurahInQueue
                            ? null
                            : (newValue) {
                                if (hasTimelineDuration) {
                                  _seekInSurahTimeline(
                                    Duration(milliseconds: newValue.round()),
                                  );
                                  return;
                                }

                                final targetIndex = newValue
                                    .floor()
                                    .clamp(0, fallbackTotalAyahs - 1)
                                    .toInt();
                                audioHandler.player.seek(
                                  Duration.zero,
                                  index: targetIndex,
                                );
                              },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hasTimelineDuration
                                ? _formatTime(surahPosition)
                                : 'Ayah ${currentIndex + 1}/$fallbackTotalAyahs',
                            style: textTheme.labelSmall?.copyWith(
                              color: context.palette.textMuted,
                            ),
                          ),
                          Text(
                            hasTimelineDuration
                                ? _formatTime(totalDuration)
                                : 'Surah total',
                            style: textTheme.labelSmall?.copyWith(
                              color: context.palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GoldIconButton(
                          icon: Icons.skip_previous_rounded,
                          onTap: _isCurrentSurahInQueue
                              ? () => audioHandler.skipToPrevious()
                              : null,
                        ),
                        _PlayButton(
                          onTap: _togglePlayback,
                          isLoading: _isPreparingPlayback,
                        ),
                        GoldIconButton(
                          icon: Icons.skip_next_rounded,
                          onTap: _isCurrentSurahInQueue
                              ? () => audioHandler.skipToNext()
                              : null,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxAppBar(
        title: Text(widget.englishName),
        subtitle: Text(widget.surahName),
        showBack: true,
        actions: [
          GoldIconButton(
            icon: Icons.tune_rounded,
            onTap: _showReadingOptions,
          ),
        ],
      ),
      body: ScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          itemCount: _surahData!.ayahs.length,
                          itemBuilder: (context, index) =>
                              _ayahCard(_surahData!.ayahs[index]),
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: _audioBar(),
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({
    required this.onTap,
    required this.isLoading,
  });

  final Future<void> Function() onTap;
  final bool isLoading;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.playBreath,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        width: AppSizes.playButton,
        height: AppSizes.playButton,
        alignment: Alignment.center,
        child: SizedBox(
          width: AppSpacing.lg,
          height: AppSpacing.lg,
          child: CircularProgressIndicator(
            strokeWidth:
                AppSizes.dividerThickness + AppSpacing.xs / AppSpacing.sm,
            color: context.palette.goldPrimary,
          ),
        ),
      );
    }

    return StreamBuilder<bool>(
      stream: audioHandler.player.playingStream,
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final scale = playing ? (1 + (_controller.value * 0.05)) : 1.0;
            return Transform.scale(
              scale: scale,
              child: GoldIconButton(
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: AppSizes.playButton,
                onTap: widget.onTap,
              ),
            );
          },
        );
      },
    );
  }
}
