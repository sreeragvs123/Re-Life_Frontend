import 'package:flutter/material.dart';
import '../data/donation_data.dart';
import '../models/donation.dart';

class VolunteerDonationPage extends StatefulWidget {
  const VolunteerDonationPage({super.key});

  @override
  State<VolunteerDonationPage> createState() => _VolunteerDonationPageState();
}

class _VolunteerDonationPageState extends State<VolunteerDonationPage> {
  final List<String> statusOptions = [
    "Pending",
    "Approved",
    "On the way",
    "Delivered"
  ];

  void _updateStatus(Donation donation, String status) {
    setState(() {
      donation.status = status;
    });
  }

  Color _statusColor(Donation donation) {
    switch (donation.status) {
      case "Pending":
        return Colors.orange;
      case "Approved":
        return Colors.blue;
      case "On the way":
        return Colors.teal;
      case "Delivered":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final approvedDonations =
        donationsList.where((d) => d.isApproved).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Volunteer: Update Status")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: approvedDonations.isEmpty
            ? const Center(child: Text("No approved donations"))
            : ListView.builder(
                itemCount: approvedDonations.length,
                itemBuilder: (context, index) {
                  final donation = approvedDonations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(donation.item,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Quantity: ${donation.quantity}"),
                          Text("Donor: ${donation.donorName}"),
                          Text("Contact: ${donation.contact}"),
                          Text("Address: ${donation.address}"),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: _statusColor(donation),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  donation.status,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              DropdownButton<String>(
                                value: donation.status,
                                items: statusOptions
                                    .map((e) =>
                                        DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) _updateStatus(donation, val);
                                },
                              )
                            ],
                          )
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
