// lib/pages/admin_volunteer_list_page.dart
//
// ⭐ Fetches volunteers from Hive (registered via VolunteerRegistrationPage)
//    and tasks from /api/group-tasks via GroupTaskApi.
//    Groups volunteers by place, shows tasks per group, allows assigning.

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/group_task_api.dart';
import '../models/group_task.dart';
import 'admin_assign_task_page.dart';

class AdminVolunteerListPage extends StatefulWidget {
  const AdminVolunteerListPage({super.key});

  @override
  State<AdminVolunteerListPage> createState() => _AdminVolunteerListPageState();
}

class _AdminVolunteerListPageState extends State<AdminVolunteerListPage> {
  late Box _volunteersBox;

  // place → list of tasks fetched from API
  Map<String, List<GroupTask>> _tasksByPlace = {};
  bool _tasksLoading = true;

  @override
  void initState() {
    super.initState();
    _volunteersBox = Hive.box('volunteersBox');
    _fetchAllTasks();
  }

  Future<void> _fetchAllTasks() async {
    setState(() => _tasksLoading = true);
    try {
      final all = await GroupTaskApi.getAllGroupTasks();
      if (mounted) {
        final Map<String, List<GroupTask>> grouped = {};
        for (final t in all) {
          grouped.putIfAbsent(t.place, () => []);
          grouped[t.place]!.add(t);
        }
        setState(() => _tasksByPlace = grouped);
      }
    } catch (_) {
      // silently fail — tasks section will just be empty
    } finally {
      if (mounted) setState(() => _tasksLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Groups'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllTasks,
            tooltip: 'Refresh tasks',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _volunteersBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No volunteers registered yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          // Group volunteers by place
          final Map<String, List<Map>> grouped = {};
          for (final v in box.values) {
            final place = v['place'] as String;
            grouped.putIfAbsent(place, () => []);
            grouped[place]!.add(v as Map);
          }

          return RefreshIndicator(
            onRefresh: _fetchAllTasks,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: grouped.entries.map((entry) {
                final place      = entry.key;
                final volunteers = entry.value;
                final tasks      = _tasksByPlace[place] ?? [];

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  color: Colors.teal.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        place[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      'Group: $place',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    subtitle: Text(
                      '${volunteers.length} volunteer(s) • ${tasks.length} task(s)',
                      style: TextStyle(color: Colors.teal.shade400),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    children: [
                      // ── Volunteer chips ──────────────────────────────
                      Wrap(
                        spacing: 6,
                        runSpacing: -4,
                        children: volunteers
                            .map((v) => Chip(
                                  avatar: const Icon(Icons.person,
                                      size: 18, color: Colors.white),
                                  label: Text(v['name']),
                                  backgroundColor: Colors.teal.shade200,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                ))
                            .toList(),
                      ),

                      // ── Tasks ────────────────────────────────────────
                      if (_tasksLoading)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                              color: Colors.teal),
                        )
                      else if (tasks.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text('Assigned Tasks:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 6),
                        ...tasks.map((t) => Card(
                              color: Colors.orange.shade100,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: const Icon(Icons.task_alt,
                                    color: Colors.orange),
                                title: Text(t.task),
                              ),
                            )),
                      ],

                      const SizedBox(height: 10),

                      // ── Assign Task button ───────────────────────────
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminAssignTaskPage(place: place),
                            ),
                          );
                          _fetchAllTasks(); // refresh after returning
                        },
                        icon: const Icon(Icons.add_task),
                        label: const Text('Assign Task',
                            style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}