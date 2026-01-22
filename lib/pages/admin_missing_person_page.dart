import 'package:flutter/material.dart';
import '../models/missing_person.dart';

class AdminMissingPersonPage extends StatefulWidget {
  final List<MissingPerson> persons;

  const AdminMissingPersonPage({super.key, required this.persons});

  @override
  State<AdminMissingPersonPage> createState() =>
      _AdminMissingPersonPageState();
}

class _AdminMissingPersonPageState extends State<AdminMissingPersonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Missing Persons",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.indigoAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: widget.persons.isEmpty
            ? const Center(
                child: Text(
                  "🎉 No Missing Persons Reported!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: widget.persons.length,
                itemBuilder: (context, index) {
                  final person = widget.persons[index];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: person.isFound ? Colors.green : Colors.teal,
                        child: Text(
                          person.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        person.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Age: ${person.age}"),
                            Text("Last Seen: ${person.lastSeen}"),
                            Text("Family: ${person.familyName}"),
                            Text("Contact: ${person.familyContact}"),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                person.isFound ? "Found" : "Missing",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: person.isFound
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                      trailing: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              person.isFound ? Colors.grey : Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            widget.persons.remove(person); // admin can delete found person
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Person removed ✅"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text("Delete"),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
