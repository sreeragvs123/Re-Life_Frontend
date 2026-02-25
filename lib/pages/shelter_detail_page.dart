import 'package:flutter/material.dart';
import '../models/shelter_model.dart';

class ShelterDetailPage extends StatelessWidget {
  final Shelter shelter;   // ⭐ Full object from API instead of just a name string

  const ShelterDetailPage({super.key, required this.shelter});

  @override
  Widget build(BuildContext context) {
    // Capacity fields — show N/A until backend adds filledCount
    final capacity = shelter.capacity != null
        ? shelter.capacity.toString()
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shelter.name,
          style: const TextStyle(
              color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.indigo),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Title ──────────────────────────────────────────────
                  Text(
                    shelter.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),

                  // ── Details grid ───────────────────────────────────────
                  _detailRow(Icons.people, "Capacity", capacity),

                  if (shelter.address != null)
                    _detailRow(Icons.location_on, "Address", shelter.address!),

                  _detailRow(
                    Icons.gps_fixed,
                    "Coordinates",
                    '${shelter.latitude.toStringAsFixed(5)}, '
                        '${shelter.longitude.toStringAsFixed(5)}',
                  ),

                  if (shelter.id != null)
                    _detailRow(Icons.tag, "ID", shelter.id.toString()),

                  const SizedBox(height: 16),

                  // ── Note about fields not yet in backend ───────────────
                  if (shelter.capacity == null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.amber, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Capacity and occupancy data will appear once '
                              'those fields are added to the backend.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for consistent detail rows
  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}