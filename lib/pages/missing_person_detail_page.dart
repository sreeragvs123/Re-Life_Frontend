import 'package:flutter/material.dart';
import '../models/missing_person.dart';

class MissingPersonDetailPage extends StatelessWidget {
  final MissingPerson person;
  final VoidCallback onMarkedFound; // Callback to notify parent/admin

  const MissingPersonDetailPage({
    super.key,
    required this.person,
    required this.onMarkedFound,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person.name, style: const TextStyle(color: Colors.teal)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
        elevation: 2,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Age: ${person.age}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Description: ${person.description}"),
                  const SizedBox(height: 8),
                  Text("Last Seen: ${person.lastSeen}"),
                  const SizedBox(height: 8),
                  Text("Family: ${person.familyName}"),
                  Text("Contact: ${person.familyContact}"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.visibility),
                    label: const Text("I saw this person"),
                    onPressed: () {
                      // Call the parent callback to mark as found
                      onMarkedFound();

                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Thank you!"),
                          content: Text(
                              "The family (${person.familyName}) has been notified."),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
