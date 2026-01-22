import 'package:flutter/material.dart';
import '../../data/donation_data.dart';
import '../../models/donation.dart';

class UserDonationPage extends StatefulWidget {
  const UserDonationPage({super.key, required String userAddress, required String userContact, required String userName});

  @override
  State<UserDonationPage> createState() => _UserDonationPageState();
}

class _UserDonationPageState extends State<UserDonationPage> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();

  void _submitDonation() {
    if (_nameController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _itemController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final donation = Donation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      donorName: _nameController.text,
      contact: _contactController.text,
      address: _addressController.text,
      item: _itemController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0, 
      date: DateTime.now(),
    );

    setState(() {
      donationsList.add(donation);
    });

    _itemController.clear();
    _quantityController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Donation submitted! Waiting for admin approval.")),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
      appBar: AppBar(title: const Text("Donate & My Donations")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // User info
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: "Contact Number / Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: "Item",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitDonation,
                  child: const Text("Donate"),
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Approved Donations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              approvedDonations.isEmpty
                  ? const Text("No approved donations yet.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: approvedDonations.length,
                      itemBuilder: (context, index) {
                        final donation = approvedDonations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(donation.item),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Quantity: ${donation.quantity}"),
                                Text(
                                    "Date: ${donation.date.toLocal().toString().split('.')[0]}"),
                                Text(
                                  "Status: ${donation.status}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(donation.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
