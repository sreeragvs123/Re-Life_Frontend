import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../api/report_api.dart';          // ⭐ NEW

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  List<Report> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final reports = await ReportApi.getAllReports();
      if (mounted) setState(() => _reports = reports);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group reports by their group field
    final groupReports = <String, List<Report>>{};
    for (final r in _reports) {
      groupReports[r.group] = groupReports[r.group] ?? [];
      groupReports[r.group]!.add(r);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Reports'),
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Failed to load:\n$_error',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadReports,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : _reports.isEmpty
                  ? const Center(
                      child: Text('No reports submitted yet.',
                          style: TextStyle(color: Colors.grey)))
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: groupReports.entries.map((entry) {
                        return ExpansionTile(
                          title: Text(
                            '${entry.key} (${entry.value.length} reports)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: entry.value.map((r) {
                            return ListTile(
                              title: Text('${r.volunteerName} — ${r.task}'),
                              subtitle: Text(r.description),
                              trailing: Text(
                                  '${r.date.day}/${r.date.month}/${r.date.year}'),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
    );
  }
}