// lib/pages/admin_assign_task_page.dart
//
// ⭐ Admin assigns tasks to a volunteer group (by place).
//    POSTs to /api/group-tasks and lists current tasks for that place.

import 'package:flutter/material.dart';
import '../api/group_task_api.dart';
import '../models/group_task.dart';

class AdminAssignTaskPage extends StatefulWidget {
  final String place;
  const AdminAssignTaskPage({super.key, required this.place});

  @override
  State<AdminAssignTaskPage> createState() => _AdminAssignTaskPageState();
}

class _AdminAssignTaskPageState extends State<AdminAssignTaskPage> {
  final _taskController = TextEditingController();
  List<GroupTask> _tasks = [];
  bool _loading          = true;
  bool _submitting       = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tasks = await GroupTaskApi.getTasksByPlace(widget.place);
      if (mounted) setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _assignTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await GroupTaskApi.createGroupTask(
        GroupTask(place: widget.place, task: text),
      );
      _taskController.clear();
      await _fetchTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Task assigned to ${widget.place}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deleteTask(GroupTask task) async {
    if (task.id == null) return;
    try {
      await GroupTaskApi.deleteGroupTask(task.id!);
      _fetchTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Task — ${widget.place}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTasks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Input ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Enter Task',
                      prefixIcon: const Icon(Icons.add_task,
                          color: Colors.teal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onSubmitted: (_) => _assignTask(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _submitting ? null : _assignTask,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Assign'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Task list ─────────────────────────────────────────────────
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
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
    if (_tasks.isEmpty) {
      return const Center(
        child: Text('No tasks assigned yet',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTasks,
      child: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.task_alt, color: Colors.white, size: 20),
              ),
              title: Text(task.task,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: task.createdAt != null
                  ? Text(
                      task.createdAt!.toLocal().toString().split('.')[0],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteTask(task),
                tooltip: 'Delete task',
              ),
            ),
          );
        },
      ),
    );
  }
}