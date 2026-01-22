import 'package:flutter/material.dart';

class ShelterDetailPage extends StatelessWidget {
  final String name;
  const ShelterDetailPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with white background and back button
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.indigo),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Gradient background
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Details for $name",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text("Capacity: 100"),
                  const Text("Occupied: 40"),
                  const Text("Location: City Center"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
