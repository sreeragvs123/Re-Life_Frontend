import 'package:flutter/material.dart';
import '../data/volunteer_data.dart';

class AdminAssignTaskPage extends StatefulWidget {
  final String place;
  const AdminAssignTaskPage({super.key, required this.place});

  @override
  State<AdminAssignTaskPage> createState() => _AdminAssignTaskPageState();
}

class _AdminAssignTaskPageState extends State<AdminAssignTaskPage> {
  final _taskController = TextEditingController();

  void _assignTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        groupTasks.putIfAbsent(widget.place, () => []);
        groupTasks[widget.place]!.add(_taskController.text);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task added for ${widget.place}")),
      );
      _taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = groupTasks[widget.place] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Assign Task - ${widget.place}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: "Enter Task"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _assignTask,
              child: const Text("Assign Task"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("No tasks yet"))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(tasks[index]),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
