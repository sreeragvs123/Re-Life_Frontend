// lib/pages/add_shelter_route_page.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map_picker_page.dart';
import '../models/shelter.dart';
import '../models/evacuation_route.dart';
import '../data/shelter_data.dart';
import '../data/evacuation_routes_data.dart';

class AddShelterRoutePage extends StatefulWidget {
  const AddShelterRoutePage({super.key});

  @override
  State<AddShelterRoutePage> createState() => _AddShelterRoutePageState();
}

class _AddShelterRoutePageState extends State<AddShelterRoutePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _filledController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();

  ll.LatLng? shelterLatLng;

  // reverse geocode to get a human readable address (optional)
  Future<String?> _reverseGeocode(double lat, double lng) async {
    const String apiKey =
        String.fromEnvironment(' AIzaSyDk5-TmduiN-vjC2i2POHwJqmTePuufVnY', defaultValue: '');
    if (apiKey.isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      'key': apiKey,
    });
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        final results = json['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          return results.first['formatted_address'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }

  void _saveShelter() {
    if (_formKey.currentState!.validate() && shelterLatLng != null) {
      final newShelter = Shelter(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        filled: int.parse(_filledController.text.trim()),
        contact: _contactController.text.trim(),
        location: _locationController.text.trim(),
        latitude: shelterLatLng!.latitude,
        longitude: shelterLatLng!.longitude,
      );

      shelters.add(newShelter);

      evacuationRoutes.add(EvacuationRoute(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        shelterId: newShelter.id,
        name: newShelter.name,
        path: [ll.LatLng(8.8932, 76.6141), shelterLatLng!],
        shelterLocation: shelterLatLng!,
      ));

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select shelter location on map")),
      );
    }
  }



  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _filledController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Shelter & Route")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Shelter Name"),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter shelter name"
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Capacity"),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter capacity"
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _filledController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Currently Filled"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter filled" : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: "Contact"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter contact" : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: "Address"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter address" : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push<ll.LatLng?>(
                        MaterialPageRoute(
                          builder: (_) => MapPickerPage(initial: shelterLatLng),
                        ),
                      );
                      if (result != null) {
                        setState(() => shelterLatLng = result);
                        // optionally reverse-geocode here (call your existing _reverseGeocode)
                        final addr = await _reverseGeocode(result.latitude, result.longitude);
                        if (!mounted) return;
                        if (addr != null && addr.isNotEmpty) {
                          _locationController.text = addr;
                        } else {
                          _locationController.text =
                              '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
                        }
                      }
                    },
                    child: const Text("Pick Shelter Location on Map"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveShelter,
                    child: const Text("Save Shelter"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
