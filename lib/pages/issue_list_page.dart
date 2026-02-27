// lib/pages/issue_list_page.dart
//
// ⭐ Fully API-driven — fetches from /api/issues via IssueApi.
//    Used by both AdminIssuePage and VolunteerIssuePage (pass role label).
//    Admin gets a delete button; Volunteer is read-only.

import 'package:flutter/material.dart';
import '../api/issue_api.dart';
import '../models/issue_model.dart';

class IssueListPage extends StatefulWidget {
  final String role; // "Admin" or "Volunteer"

  const IssueListPage({super.key, required this.role});

  @override
  State<IssueListPage> createState() => _IssueListPageState();
}

class _IssueListPageState extends State<IssueListPage> {
  List<Issue> _issues  = [];
  bool _loading        = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchIssues();
  }

  Future<void> _fetchIssues() async {
    setState(() {
      _loading = true;
      _error   = null;
    });
    try {
      final issues = await IssueApi.getAllIssues();
      if (mounted) setState(() => _issues = issues);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteIssue(Issue issue) async {
    if (issue.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Issue'),
        content: Text('Remove "${issue.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await IssueApi.deleteIssue(issue.id!);
        _fetchIssues();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':   return Colors.redAccent;
      case 'medium': return Colors.orangeAccent;
      case 'low':    return Colors.green;
      default:       return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role}: Reported Issues',
            style: const TextStyle(color: Colors.teal)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal),
            onPressed: _fetchIssues,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildBody(isAdmin),
      ),
    );
  }

  Widget _buildBody(bool isAdmin) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _fetchIssues, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_issues.isEmpty) {
      return const Center(
        child: Text(
          'No issues reported yet.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchIssues,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _issues.length,
        itemBuilder: (context, index) =>
            _buildIssueCard(_issues[index], isAdmin),
      ),
    );
  }

  Widget _buildIssueCard(Issue issue, bool isAdmin) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.teal.shade50.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Title row + delete button (admin only) ─────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.report_problem, color: Colors.teal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    issue.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87),
                  ),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete issue',
                    onPressed: () => _deleteIssue(issue),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Reporter ───────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 4),
                Text('${issue.name} (${issue.email})',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
            if (issue.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18),
                  const SizedBox(width: 4),
                  Text(issue.phone!,
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],

            // ── Category / Priority / Location chips ───────────────────
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                if (issue.category != null)
                  Chip(
                    label: Text(issue.category!),
                    avatar: const Icon(Icons.category,
                        size: 18, color: Colors.white),
                    backgroundColor: Colors.teal,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                if (issue.priority != null)
                  Chip(
                    label: Text(issue.priority!),
                    avatar: const Icon(Icons.flag,
                        size: 18, color: Colors.white),
                    backgroundColor: _getPriorityColor(issue.priority),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                if (issue.location != null)
                  Chip(
                    label: Text(issue.location!),
                    avatar: const Icon(Icons.location_on,
                        size: 18, color: Colors.white),
                    backgroundColor: Colors.teal.shade700,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),

            // ── Date ───────────────────────────────────────────────────
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  issue.date.toLocal().toString().split('.')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            // ── Description ────────────────────────────────────────────
            const SizedBox(height: 8),
            Text(
              issue.description,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),

            // ── Attachment preview (base64 → bytes) ────────────────────
            if (issue.attachment != null && issue.attachment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  issue.attachment!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}