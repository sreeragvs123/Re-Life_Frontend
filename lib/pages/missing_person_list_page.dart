import 'package:flutter/material.dart';
import '../models/missing_person.dart';
import 'report_missing_person_page.dart';
import 'missing_person_detail_page.dart';
// ⭐ ADDED: Import API service
import '../api/missing_person_api.dart';

class MissingPersonListPage extends StatefulWidget {
  const MissingPersonListPage({super.key});

  @override
  State<MissingPersonListPage> createState() => _MissingPersonListPageState();
}

class _MissingPersonListPageState extends State<MissingPersonListPage> {
  // ⭐ CHANGED: Now fetched from backend instead of passed as parameter
  List<MissingPerson> _persons = [];
  bool _isLoading = true;
  final MissingPersonApi _api = MissingPersonApi();

  @override
  void initState() {
    super.initState();
    _loadPersons(); // ⭐ ADDED: Load persons from backend on init
  }

  // ⭐ ADDED: Fetch all missing persons from backend
  Future<void> _loadPersons() async {
    setState(() => _isLoading = true);
    try {
      final persons = await _api.getAll();
      setState(() {
        _persons = persons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading persons: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ⭐ EDITED: Toggle found/not found with backend API call
  Future<void> _toggleFound(MissingPerson person) async {
    try {
      // Update in backend first
      await _api.updateStatus(int.parse(person.id), !person.isFound);
      
      // Update UI after successful backend update
      setState(() {
        person.isFound = !person.isFound;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(person.isFound 
              ? '${person.name} marked as Found' 
              : '${person.name} marked as Missing'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ⭐ EDITED: Add new person is now handled in ReportMissingPersonPage
  // This just refreshes the list after adding
  Future<void> _refreshAfterAdd() async {
    await _loadPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Missing Persons", style: TextStyle(color: Colors.teal)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
        elevation: 2,
        // ⭐ ADDED: Refresh button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPersons,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // ⭐ ADDED: Loading indicator
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _persons.isEmpty
                ? const Center(
                    child: Text(
                      "No missing persons reported yet",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPersons,
                    child: ListView.builder(
                      itemCount: _persons.length,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemBuilder: (context, index) {
                        final person = _persons[index];
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
                                    onMarkedFound: () async {
                                      // ⭐ EDITED: Use API to update status
                                      await _toggleFound(person);
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // ⭐ EDITED: Navigate and refresh after adding
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportMissingPersonPage(),
            ),
          );
          
          // Refresh list if person was added
          if (result == true) {
            _refreshAfterAdd();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Report Missing"),
        backgroundColor: Colors.teal,
      ),
    );
  }
}