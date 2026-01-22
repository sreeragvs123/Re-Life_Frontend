import 'package:flutter/material.dart';
import '../data/report_data.dart';
import '../models/report_model.dart';

class AdminReportPage extends StatelessWidget {
  const AdminReportPage({super.key, required volunteerName});

  @override
  Widget build(BuildContext context) {
    final groupReports = <String, List<Report>>{};

    for (var r in reports) {
      groupReports[r.group] = groupReports[r.group] ?? [];
      groupReports[r.group]!.add(r);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Reports"),
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
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: groupReports.entries.map((entry) {
          final group = entry.key;
          final reportsList = entry.value;

          return ExpansionTile(
            title: Text("$group (${reportsList.length} reports)"),
            children: reportsList.map((r) {
              return ListTile(
                title: Text("${r.volunteerName} - ${r.task}"),
                subtitle: Text(r.description),
                trailing: Text("${r.date.day}/${r.date.month}/${r.date.year}"),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
