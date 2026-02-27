import 'package:flutter/material.dart';
import '../models/issue_model.dart';
import '../api/issue_api.dart';

/// Volunteers can VIEW user-reported issues (read-only).
/// Only Admin can delete them — see AdminIssuePage.
class VolunteerIssuePage extends StatefulWidget {
  const VolunteerIssuePage({super.key});

  @override
  State<VolunteerIssuePage> createState() => _VolunteerIssuePageState();
}

class _VolunteerIssuePageState extends State<VolunteerIssuePage> {
  List<Issue> _issues = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final issues = await IssueApi.getAllIssues();
      if (mounted) setState(() => _issues = issues);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _priorityColor(String? p) {
    switch (p) {
      case 'Urgent': return Colors.red;
      case 'High':   return Colors.orange;
      case 'Medium': return Colors.amber;
      default:       return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Issues'),
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadIssues),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Failed to load:\n$_error', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadIssues,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : _issues.isEmpty
                  ? const Center(
                      child: Text('No issues reported by users yet.',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _issues.length,
                      itemBuilder: (context, index) {
                        final issue = _issues[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _priorityColor(issue.priority),
                              child: Text(
                                issue.priority?[0] ?? '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(issue.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${issue.name} · ${issue.category ?? "No category"}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _row('Email', issue.email),
                                    if (issue.phone != null)
                                      _row('Phone', issue.phone!),
                                    if (issue.location != null)
                                      _row('Location', issue.location!),
                                    _row('Priority', issue.priority ?? 'N/A'),
                                    const SizedBox(height: 6),
                                    const Text('Description:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(issue.description),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Reported: ${issue.date.day}/${issue.date.month}/${issue.date.year}',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                    if (issue.attachment != null) ...[
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          issue.attachment!,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}