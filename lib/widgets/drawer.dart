import 'package:flutter/material.dart';
import 'package:quran_app/pages/voice_picker.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          ListTile(
            title: const Text('Select Voice'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoicePicker(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Select Theme'),
            onTap: () {
              Navigator.pushNamed(context, '/theme');
            },
          ),
        ],
      ),
    );
  }
}
