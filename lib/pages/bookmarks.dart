import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quran_app/pages/surah_reading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final b = prefs.getString('bookmarks');
    if (b != null) {
      final list = List<Map<String, dynamic>>.from(jsonDecode(b));
      list.sort((a, b) =>
          (b['timestamp'] as String).compareTo(a['timestamp'] as String));
      setState(() {
        _bookmarks = list;
      });
    }
  }

  Future<void> _deleteBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarks.removeAt(index);
    });
    await prefs.setString('bookmarks', jsonEncode(_bookmarks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: _bookmarks.isEmpty
          ? const Center(child: Text('No bookmarks finding.'))
          : ListView.builder(
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final b = _bookmarks[index];
                return ListTile(
                  title: Text('${b['englishName']} - Ayah ${b['ayahNumber']}'),
                  subtitle: Text(b['surahName'] ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahReadingScreen(
                          surahNumber: b['surahNumber'],
                          surahName: b['surahName'] ?? '',
                          englishName: b['englishName'],
                          initialAyahNumber: b['ayahNumber'],
                        ),
                      ),
                    ).then((_) => _loadBookmarks());
                  },
                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Bookmark?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _deleteBookmark(index);
                    }
                  },
                );
              },
            ),
    );
  }
}
