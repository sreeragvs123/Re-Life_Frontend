import 'package:flutter/material.dart';
import '../models/missing_person.dart';
import 'report_missing_person_page.dart';
import 'missing_person_detail_page.dart';

class MissingPersonListPage extends StatefulWidget {
  final List<MissingPerson> persons;

  const MissingPersonListPage({super.key, required this.persons});

  @override
  State<MissingPersonListPage> createState() => _MissingPersonListPageState();
}

class _MissingPersonListPageState extends State<MissingPersonListPage> {
  // Toggle found/not found
  void _toggleFound(MissingPerson person) {
    setState(() {
      person.isFound = !person.isFound;
    });
  }

  // Add a new missing person
  void _addPerson(MissingPerson person) {
    setState(() {
      widget.persons.add(person);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Missing Persons", style: TextStyle(color: Colors.teal)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: widget.persons.isEmpty
            ? const Center(
                child: Text(
                  "No missing persons reported yet",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              )
            : ListView.builder(
                itemCount: widget.persons.length,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (context, index) {
                  final person = widget.persons[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shadowColor: Colors.black38,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal.shade100,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      title: Text(
                        person.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Age: ${person.age}"),
                            Text("Last seen: ${person.lastSeen}"),
                            const SizedBox(height: 6),
                            Chip(
                              label: Text(
                                person.isFound ? "Found" : "Missing",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: person.isFound
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _toggleFound(person),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              person.isFound ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          person.isFound ? "Mark Missing" : "Mark Found",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      onTap: () {
                        // Open detail page with callback
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MissingPersonDetailPage(
                              person: person,
                              onMarkedFound: () {
                                setState(() {
                                  person.isFound = true;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newPerson = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportMissingPersonPage(),
            ),
          );
          if (newPerson != null) {
            _addPerson(newPerson);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Report Missing"),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
