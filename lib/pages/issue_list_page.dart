import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../data/issue_data.dart';
import '../models/issue_model.dart';

class IssueListPage extends StatelessWidget {
  final String role;

  const IssueListPage({super.key, required this.role});

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case "high":
        return Colors.redAccent;
      case "medium":
        return Colors.orangeAccent;
      case "low":
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$role: Reported Issues", style: const TextStyle(color: Colors.teal)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: issues.isEmpty
            ? const Center(
                child: Text(
                  "No issues reported yet.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.95), Colors.teal.shade50.withOpacity(0.9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Row(
                            children: [
                              const Icon(Icons.report_problem, color: Colors.teal),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  issue.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Reporter Info
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18),
                              const SizedBox(width: 4),
                              Text("${issue.name} (${issue.email})",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          if (issue.phone != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 18),
                                const SizedBox(width: 4),
                                Text(issue.phone!, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],

                          // Category & Priority Chips
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (issue.category != null)
                                Chip(
                                  label: Text(issue.category!),
                                  avatar: const Icon(Icons.category, size: 18, color: Colors.white),
                                  backgroundColor: Colors.teal,
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                              if (issue.priority != null)
                                Chip(
                                  label: Text(issue.priority!),
                                  avatar: const Icon(Icons.flag, size: 18, color: Colors.white),
                                  backgroundColor: _getPriorityColor(issue.priority),
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                              if (issue.location != null)
                                Chip(
                                  label: Text(issue.location!),
                                  avatar: const Icon(Icons.location_on, size: 18, color: Colors.white),
                                  backgroundColor: Colors.teal.shade700,
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                            ],
                          ),

                          // Date
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                issue.date.toLocal().toString().split(".")[0],
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),

                          // Description
                          const SizedBox(height: 8),
                          Text(
                            issue.description,
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),

                          // Attachment preview
                          if (issue.attachment != null) ...[
                            const SizedBox(height: 10),
                            if (kIsWeb || !issue.attachment!.isEmpty)
                              Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black12,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    issue.attachment!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
