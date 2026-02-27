// lib/pages/volunteer_report_page.dart
//
// ⭐ Groups and tasks are loaded from /api/group-tasks via GroupTaskApi.
//    No more local groupTasks map from volunteer_data.dart.

import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/group_task.dart';
import '../api/report_api.dart';
import '../api/group_task_api.dart';

class VolunteerReportPage extends StatefulWidget {
  final String volunteerName;
  const VolunteerReportPage({super.key, required this.volunteerName});

  @override
  State<VolunteerReportPage> createState() => _VolunteerReportPageState();
}

class _VolunteerReportPageState extends State<VolunteerReportPage> {
  // ── Form state ─────────────────────────────────────────────────────────────
  String? _selectedGroup;
  String? _selectedTask;
  final _descriptionController = TextEditingController();

  // ── API state ──────────────────────────────────────────────────────────────
  // place → list of task strings fetched from /api/group-tasks
  Map<String, List<String>> _groupTasks = {};
  bool _groupsLoading  = true;

  List<Report> _myReports  = [];
  bool _reportsLoading     = true;
  bool _isSubmitting       = false;

  @override
  void initState() {
    super.initState();
    _loadGroupTasks();
    _loadMyReports();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Load groups + tasks from API ───────────────────────────────────────────
  Future<void> _loadGroupTasks() async {
    setState(() => _groupsLoading = true);
    try {
      final all = await GroupTaskApi.getAllGroupTasks();
      if (mounted) {
        // Build place → [task strings] map
        final Map<String, List<String>> map = {};
        for (final GroupTask gt in all) {
          map.putIfAbsent(gt.place, () => []);
          map[gt.place]!.add(gt.task);
        }
        setState(() {
          _groupTasks    = map;
          // Reset selections if they no longer exist in refreshed data
          if (_selectedGroup != null && !map.containsKey(_selectedGroup)) {
            _selectedGroup = null;
            _selectedTask  = null;
          }
          if (_selectedTask != null &&
              !(_groupTasks[_selectedGroup] ?? []).contains(_selectedTask)) {
            _selectedTask = null;
          }
        });
      }
    } catch (_) {
      // Non-critical — dropdowns stay empty
    } finally {
      if (mounted) setState(() => _groupsLoading = false);
    }
  }

  // ── Load this volunteer's past reports ─────────────────────────────────────
  Future<void> _loadMyReports() async {
    setState(() => _reportsLoading = true);
    try {
      final reports =
          await ReportApi.getReportsByVolunteer(widget.volunteerName);
      if (mounted) setState(() => _myReports = reports);
    } catch (_) {
      // Non-critical — list stays empty
    } finally {
      if (mounted) setState(() => _reportsLoading = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadGroupTasks(), _loadMyReports()]);
  }

  // ── Submit report ──────────────────────────────────────────────────────────
  Future<void> _submitReport() async {
    if (_selectedGroup == null ||
        _selectedTask == null ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newReport = await ReportApi.createReport(
        Report(
          volunteerName: widget.volunteerName,
          group:         _selectedGroup!,
          task:          _selectedTask!,
          description:   _descriptionController.text.trim(),
          date:          DateTime.now(),
        ),
      );

      if (mounted) {
        setState(() {
          _myReports.insert(0, newReport);
          _descriptionController.clear();
          _selectedGroup = null;
          _selectedTask  = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Tasks available for the currently selected group
    final List<String> tasksForGroup =
        _selectedGroup != null ? (_groupTasks[_selectedGroup!] ?? []) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Volunteer Report'),
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
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Group dropdown ─────────────────────────────────────────────
            _groupsLoading
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Group',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.group, color: Colors.deepPurple),
                    ),
                    value: _selectedGroup,
                    hint: _groupTasks.isEmpty
                        ? const Text('No groups available')
                        : const Text('Select a group'),
                    items: _groupTasks.keys
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: _groupTasks.isEmpty
                        ? null
                        : (val) => setState(() {
                              _selectedGroup = val;
                              _selectedTask  = null; // reset task on group change
                            }),
                  ),
            const SizedBox(height: 12),

            // ── Task dropdown ──────────────────────────────────────────────
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Task',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.task_alt, color: Colors.deepPurple),
              ),
              value: _selectedTask,
              hint: _selectedGroup == null
                  ? const Text('Select a group first')
                  : tasksForGroup.isEmpty
                      ? const Text('No tasks for this group')
                      : const Text('Select a task'),
              items: tasksForGroup
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: tasksForGroup.isEmpty
                  ? null
                  : (val) => setState(() => _selectedTask = val),
            ),
            const SizedBox(height: 12),

            // ── Description ────────────────────────────────────────────────
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Report Description',
                border: OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 56),
                  child: Icon(Icons.description, color: Colors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Submit button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Submit Report',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),

            // ── My Reports list ────────────────────────────────────────────
            const Text('Your Reports:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            Expanded(
              child: _reportsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _myReports.isEmpty
                      ? const Center(
                          child: Text('No reports submitted yet.',
                              style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            itemCount: _myReports.length,
                            itemBuilder: (context, index) {
                              final r = _myReports[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.deepPurple,
                                    child: Icon(Icons.report,
                                        color: Colors.white, size: 20),
                                  ),
                                  title: Text(r.task,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(r.description),
                                      const SizedBox(height: 4),
                                      Text('Group: ${r.group}',
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                              color: Colors.deepPurple)),
                                    ],
                                  ),
                                  trailing: Text(
                                    '${r.date.day}/${r.date.month}/${r.date.year}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}