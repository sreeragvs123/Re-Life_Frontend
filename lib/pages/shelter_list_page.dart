import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:Relife/models/shelter.dart';
import '../data/shelter_data.dart';
import 'add_shelter_route_page.dart';
import 'user_shelter_map_page.dart';
import 'map_picker_page.dart';

class ShelterListPage extends StatefulWidget {
  final bool isAdmin;

  const ShelterListPage({super.key, this.isAdmin = false});

  @override
  State<ShelterListPage> createState() => _ShelterListPageState();
}

class _ShelterListPageState extends State<ShelterListPage> {
  // Navigate to Add Shelter Page
  void _goToAddShelter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddShelterRoutePage()),
    );

    if (result == true) setState(() {}); // Refresh list
  }

  // Pick user's current location and view all shelters
  void _pickUserLocationForMap() async {
    final result = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(
        builder: (_) => const MapPickerPage(),
      ),
    );

    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserShelterMapPage(
            userLocation: result,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shelters"),
        centerTitle: true,
        actions: [
          Tooltip(
            message: "View all shelters on map",
            child: IconButton(
              icon: const Icon(Icons.map),
              onPressed: _pickUserLocationForMap,
            ),
          ),
        ],
      ),
      body: shelters.isEmpty
          ? const Center(child: Text("No shelters available"))
          : ListView.builder(
              itemCount: shelters.length,
              itemBuilder: (_, index) {
                final shelter = shelters[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(shelter.name),
                    subtitle: Text(
                        "${shelter.location} | ${shelter.filled}/${shelter.capacity}"),
                    trailing:
                        const Icon(Icons.location_on, color: Colors.red),
                  ),
                );
              },
            ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _goToAddShelter,
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
