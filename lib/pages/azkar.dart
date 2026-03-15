import 'package:flutter/material.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final Map<String, List<Map<String, String>>> _azkarData = {
    'Morning': [
      {'text': 'SubhanAllah', 'count': '33'},
      {'text': 'Alhamdulillah', 'count': '33'},
      {'text': 'Allahu Akbar', 'count': '34'},
    ],
    'Evening': [
      {'text': 'Astaghfirullah', 'count': '100'},
      {'text': 'La ilaha illallah', 'count': '10'},
    ],
  };

  String _selectedCategory = 'Morning';

  @override
  Widget build(BuildContext context) {
    final list = _azkarData[_selectedCategory] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hisn al-Muslim (Azkar)'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _azkarData.keys.map((cat) {
              return ChoiceChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (val) {
                  if (val) setState(() => _selectedCategory = cat);
                },
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return ListTile(
                  title: Text(item['text'] ?? ''),
                  subtitle: Text('Repeat: ${item['count']} times'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Counted!')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
