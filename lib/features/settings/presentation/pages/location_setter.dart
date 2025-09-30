import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSetter extends StatefulWidget {
  LocationSetter({Key? key}) : super(key: key);

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
    _prefs.then((SharedPreferences prefs) {
      if (prefs.getString('city') != null) {
        _cityController.text = prefs.getString('city')!;
      }
      if (prefs.getString('country') != null) {
        _countryController.text = prefs.getString('country')!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Setter'),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[500],
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  controller: _cityController,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  controller: _countryController,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Note: the city used may not work if the data for that particular city does not exist in server. In that case please try again with the nearest city.',
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_cityController.text.isNotEmpty &&
                        _countryController.text.isNotEmpty) {
                      _prefs.then((SharedPreferences prefs) {
                        prefs.setString('city', _cityController.text);
                        prefs.setString('country', _countryController.text);
                      });
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter city and country'),
                        ),
                      );
                    }
                  },
                  child: const Text('Set Location'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
