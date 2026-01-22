import 'package:flutter/material.dart';
import '../data/volunteer_data.dart'; // Ensure this has groupTasks map

class VolunteerGroupPage extends StatefulWidget {
  const VolunteerGroupPage({super.key, required this.place});
  final String place;

  @override
  State<VolunteerGroupPage> createState() => _VolunteerGroupPageState();
}

class _VolunteerGroupPageState extends State<VolunteerGroupPage> {
  Map<String, List<String>> allTasks = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      allTasks = Map.from(groupTasks); // copy all tasks
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar look
      appBar: AppBar(
        title: const Text(
          "All Group Tasks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTasks,
            tooltip: 'Refresh Tasks',
          ),
        ],
      ),

      body: allTasks.isEmpty
          ? const Center(
              child: Text(
                "No tasks assigned yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: allTasks.entries.map((entry) {
                final place = entry.key;
                final tasks = entry.value;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.shade400,
                        Colors.teal.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  
                  child: ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    title: Text(
                      "Group: $place",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "${tasks.length} Task(s)",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    childrenPadding: const EdgeInsets.all(12),
                    children: tasks.isEmpty
                        ? [
                            const ListTile(
                              leading: Icon(Icons.info_outline,
                                  color: Colors.white),
                              title: Text(
                                "No tasks assigned yet",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ]
                        : tasks
                            .map(
                              (task) => Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  title: Text(
                                    task,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
