import 'package:flutter/material.dart';
import '../models/missing_person.dart';
// ⭐ ADDED: Import API service
import '../api/missing_person_api.dart';

class AdminMissingPersonPage extends StatefulWidget {
  const AdminMissingPersonPage({super.key});

  @override
  State<AdminMissingPersonPage> createState() =>
      _AdminMissingPersonPageState();
}

class _AdminMissingPersonPageState extends State<AdminMissingPersonPage> {
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

  // ⭐ EDITED: Delete person with backend API call
  Future<void> _deletePerson(MissingPerson person) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to remove ${person.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // ⭐ ADDED: Delete from backend
      await _api.delete(int.parse(person.id));
      
      // Remove from local list
      setState(() {
        _persons.remove(person);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Person removed ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
            colors: [Colors.teal, Colors.indigoAccent],
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
                      "🎉 No Missing Persons Reported!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPersons,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _persons.length,
                      itemBuilder: (context, index) {
                        final person = _persons[index];
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
                              // ⭐ EDITED: Use new delete method
                              onPressed: () => _deletePerson(person),
                              icon: const Icon(Icons.delete, color: Colors.white),
                              label: const Text("Delete"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}