import 'package:flutter/material.dart';
import '../data/donation_data.dart';
import '../models/donation.dart';

class AdminDonationPage extends StatefulWidget {
  const AdminDonationPage({super.key});

  @override
  State<AdminDonationPage> createState() => _AdminDonationPageState();
}

class _AdminDonationPageState extends State<AdminDonationPage> {
  void _approveDonation(Donation donation) {
    setState(() {
      donation.isApproved = true;
      donation.status = "Pending";
    });
  }

  void _rejectDonation(Donation donation) {
    setState(() {
      donationsList.remove(donation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingDonations = donationsList.where((d) => !d.isApproved).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Approve Donations")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: pendingDonations.isEmpty
            ? const Center(child: Text("No pending donations"))
            : ListView.builder(
                itemCount: pendingDonations.length,
                itemBuilder: (context, index) {
                  final donation = pendingDonations[index];
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
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => _approveDonation(donation),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text("Approve"),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _rejectDonation(donation),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text("Reject"),
                              ),
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
