import 'package:flutter/material.dart';

class LocationSetter extends StatelessWidget {
  LocationSetter({Key? key}) : super(key: key);

  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

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
                const SizedBox(height: 16),
                const Text(
                  'Note: the city used may not work if the data for that particular city does not exist in server. In that case please try again with the closest city.',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    print(_cityController.text);
                    print(_countryController.text);
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
