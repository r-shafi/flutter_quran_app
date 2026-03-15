import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<dynamic> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final res =
          await http.get(Uri.parse('https://api.hadith.gading.dev/books'));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        setState(() {
          _books = j['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hadith Books')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final b = _books[index];
                return ListTile(
                  title: Text(b['name']),
                  subtitle: Text('Total Hadith: ${b['available']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HadithListScreen(
                          bookId: b['id'],
                          bookName: b['name'],
                          totalHadith: b['available'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class HadithListScreen extends StatefulWidget {
  final String bookId;
  final String bookName;
  final int totalHadith;

  const HadithListScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.totalHadith,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final List<dynamic> _hadiths = [];
  bool _isLoading = false;
  int _rangeStart = 1;
  int _rangeEnd = 20;
  List<Map<String, dynamic>> _bookmarkedHadiths = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _fetchHadiths();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final b = prefs.getString('bookmarks_hadith');
    if (b != null) {
      setState(() {
        _bookmarkedHadiths = List<Map<String, dynamic>>.from(jsonDecode(b));
      });
    }
  }

  Future<void> _toggleBookmark(dynamic h) async {
    final prefs = await SharedPreferences.getInstance();
    final index = _bookmarkedHadiths.indexWhere(
        (b) => b['bookId'] == widget.bookId && b['number'] == h['number']);

    if (index >= 0) {
      _bookmarkedHadiths.removeAt(index);
    } else {
      _bookmarkedHadiths.add({
        'bookId': widget.bookId,
        'bookName': widget.bookName,
        'number': h['number'],
        'arab': h['arab'],
        'translation': h['id'],
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
    await prefs.setString('bookmarks_hadith', jsonEncode(_bookmarkedHadiths));
    setState(() {});
  }

  Future<void> _fetchHadiths() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final end =
          _rangeEnd > widget.totalHadith ? widget.totalHadith : _rangeEnd;
      final url =
          'https://api.hadith.gading.dev/books/${widget.bookId}?range=$_rangeStart-$end';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        setState(() {
          _hadiths.addAll(j['data']['hadiths']);
          _rangeStart += 20;
          _rangeEnd += 20;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookName)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hadiths.length + 1,
        itemBuilder: (context, index) {
          if (index == _hadiths.length) {
            return ElevatedButton(
              onPressed: _rangeStart > widget.totalHadith || _isLoading
                  ? null
                  : _fetchHadiths,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Load More'),
            );
          }

          final h = _hadiths[index];
          final isBookmarked = _bookmarkedHadiths.any((b) =>
              b['bookId'] == widget.bookId && b['number'] == h['number']);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hadith ${h['number']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border),
                        onPressed: () => _toggleBookmark(h),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    h['arab'] ?? '',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 22, height: 1.8),
                  ),
                  const Divider(height: 32),
                  Text(h['id'] ?? '', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
