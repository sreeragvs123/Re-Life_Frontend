import 'dart:ffi';

import 'package:flutter/material.dart';
import '../api/blood_api.dart';
import '../models/blood_request.dart';
import 'add_blood_request_page.dart';

class VolunteerBloodPage extends StatefulWidget {
  const VolunteerBloodPage({super.key});

  @override
  State<VolunteerBloodPage> createState() => _VolunteerBloodPageState();
}

class _VolunteerBloodPageState extends State<VolunteerBloodPage> {
  final _api = BloodApi();
  late Future<List<BloodRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blood Requests")),
      body: FutureBuilder<List<BloodRequest>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(child: Text("No requests"));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final r = list[i];
              return ListTile(
                title: Text("${r.name} (${r.bloodGroup})"),
                subtitle: Text("${r.city} | ${r.contact}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _api.delete(r.id!);
                    _refresh();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBloodRequestPage()),
          );
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
