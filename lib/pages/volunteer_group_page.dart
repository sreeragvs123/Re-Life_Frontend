// lib/pages/volunteer_group_page.dart
//
// ⭐ Volunteer sees ALL group tasks fetched from /api/group-tasks.
//    Their own group (by place) is highlighted at the top.
//    Read-only — volunteers cannot add or delete tasks.

import 'package:flutter/material.dart';
import '../api/group_task_api.dart';
import '../models/group_task.dart';

class VolunteerGroupPage extends StatefulWidget {
  final String place; // volunteer's own place/group
  const VolunteerGroupPage({super.key, required this.place});

  @override
  State<VolunteerGroupPage> createState() => _VolunteerGroupPageState();
}

class _VolunteerGroupPageState extends State<VolunteerGroupPage> {
  // place → list of tasks
  Map<String, List<GroupTask>> _tasksByPlace = {};
  bool _loading  = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() { _loading = true; _error = null; });
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
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Group Tasks',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
            onPressed: _fetchTasks,
            tooltip: 'Refresh Tasks',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _fetchTasks, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_tasksByPlace.isEmpty) {
      return const Center(
        child: Text('No tasks assigned yet',
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }

    // Sort entries so the volunteer's own group appears first
    final entries = _tasksByPlace.entries.toList()
      ..sort((a, b) {
        if (a.key == widget.place) return -1;
        if (b.key == widget.place) return 1;
        return a.key.compareTo(b.key);
      });

    return RefreshIndicator(
      onRefresh: _fetchTasks,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: entries.map((entry) {
          final place   = entry.key;
          final tasks   = entry.value;
          final isMyGroup = place == widget.place;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: isMyGroup
                    ? [Colors.deepPurple.shade400, Colors.deepPurple.shade700]
                    : [Colors.teal.shade400, Colors.teal.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 4)),
              ],
            ),
            child: ExpansionTile(
              initiallyExpanded: isMyGroup, // auto-expand own group
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              title: Row(
                children: [
                  Text(
                    'Group: $place',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  if (isMyGroup) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('My Group',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                '${tasks.length} Task(s)',
                style: const TextStyle(color: Colors.white70),
              ),
              childrenPadding: const EdgeInsets.all(12),
              children: tasks.isEmpty
                  ? [
                      const ListTile(
                        leading: Icon(Icons.info_outline, color: Colors.white),
                        title: Text('No tasks assigned yet',
                            style: TextStyle(color: Colors.white)),
                      )
                    ]
                  : tasks
                      .map((t) => Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              title: Text(t.task,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              subtitle: t.createdAt != null
                                  ? Text(
                                      t.createdAt!
                                          .toLocal()
                                          .toString()
                                          .split('.')[0],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey),
                                    )
                                  : null,
                            ),
                          ))
                      .toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}