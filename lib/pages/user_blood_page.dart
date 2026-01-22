import 'package:flutter/material.dart';
import '../models/blood_request.dart';
import '../services/blood_request_service.dart';

class UserBloodPage extends StatefulWidget {
  const UserBloodPage({super.key});

  @override
  State<UserBloodPage> createState() => _UserBloodPageState();
}

class _UserBloodPageState extends State<UserBloodPage> {
  late Future<List<BloodRequest>> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _future = BloodRequestService.fetchBloodRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Donation Requests"),
        backgroundColor: Colors.red.shade700,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loadData());
        },
        child: FutureBuilder<List<BloodRequest>>(
          future: _future,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return const Center(child: Text("No blood requests found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final r = requests[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade700,
                      child: Text(
                        r.bloodGroup,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      r.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📞 ${r.contact}"),
                        Text("📍 ${r.city}"),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
