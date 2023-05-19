import 'package:flutter/material.dart';
import 'package:quran_app/pages/location_setter.dart';
import 'package:quran_app/pages/voice_picker.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
            child: Center(
              child: Text(
                'MADE WITH 🤍 BY SHAFI RAYHAN',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
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
            leading: const Icon(Icons.mosque),
            title: const Text('Set Location'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationSetter(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Select Theme'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
