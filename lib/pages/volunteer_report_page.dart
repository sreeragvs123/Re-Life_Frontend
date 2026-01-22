import 'package:flutter/material.dart';
import 'package:Relife/data/volunteer_data.dart';
import '../data/report_data.dart'; // Make sure groupTasks and reports are defined here
import '../models/report_model.dart';

class VolunteerReportPage extends StatefulWidget {
  final String volunteerName; // To track volunteer
  const VolunteerReportPage({super.key, required this.volunteerName});

  @override
  State<VolunteerReportPage> createState() => _VolunteerReportPageState();
}

class _VolunteerReportPageState extends State<VolunteerReportPage> {
  String? selectedGroup;
  String? selectedTask;
  TextEditingController descriptionController = TextEditingController();

  void submitReport() {
    if (selectedGroup == null || selectedTask == null || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final newReport = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      volunteerName: widget.volunteerName,
      group: selectedGroup!,
      task: selectedTask!,
      description: descriptionController.text,
      date: DateTime.now(),
    );

    setState(() {
      reports.add(newReport);
      descriptionController.clear();
      selectedGroup = null;
      selectedTask = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report submitted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure tasksForGroup is always a List<String>
    final List<String> tasksForGroup = selectedGroup != null
        ? (groupTasks[selectedGroup!] as List<String>? ?? [])
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Volunteer Report"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Group",
                border: OutlineInputBorder(),
              ),
              value: selectedGroup,
              items: groupTasks.keys
                  .map((g) => DropdownMenuItem<String>(
                        value: g,
                        child: Text(g),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedGroup = val;
                  selectedTask = null; // reset task selection
                });
              },
            ),
            const SizedBox(height: 12),

            // Task dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Task",
                border: OutlineInputBorder(),
              ),
              value: selectedTask,
              items: tasksForGroup
                  .map((t) => DropdownMenuItem<String>(
                        value: t,
                        child: Text(t),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedTask = val;
                });
              },
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Report Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Submit button
            ElevatedButton(
              onPressed: submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Submit Report"),
            ),
            const SizedBox(height: 20),

            // Volunteer Reports List
            const Text(
              "Your Reports:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                children: reports
                    .where((r) => r.volunteerName == widget.volunteerName)
                    .map((r) => Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            title: Text(
                              r.task,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.description),
                                const SizedBox(height: 4),
                                Text(
                                  "Group: ${r.group}",
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Text(
                                "${r.date.day}/${r.date.month}/${r.date.year}"),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
