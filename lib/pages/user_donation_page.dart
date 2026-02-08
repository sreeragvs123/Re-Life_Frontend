import 'package:flutter/material.dart';
import '../../models/donation.dart';
import '../../api/donation_api.dart';

class UserDonationPage extends StatefulWidget {
  final String userName;
  final String userContact;
  final String userAddress;

  const UserDonationPage({
    super.key,
    required this.userName,
    required this.userContact,
    required this.userAddress,
  });

  @override
  State<UserDonationPage> createState() => _UserDonationPageState();
}

class _UserDonationPageState extends State<UserDonationPage> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();

  List<Donation> _myDonations = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill user information
    _nameController.text = widget.userName;
    _contactController.text = widget.userContact;
    _addressController.text = widget.userAddress;
    
    _loadMyDonations();
  }

  Future<void> _loadMyDonations() async {
    setState(() => _isLoading = true);
    try {
      final donations = await DonationApi.getDonationsByDonor(widget.userName);
      setState(() {
        _myDonations = donations.where((d) => d.isApproved).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading donations: $e")),
        );
      }
    }
  }

  Future<void> _submitDonation() async {
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
      donorName: _nameController.text,
      contact: _contactController.text,
      address: _addressController.text,
      item: _itemController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      date: DateTime.now(),
    );

    setState(() => _isSubmitting = true);

    try {
      await DonationApi.createDonation(donation);
      
      _itemController.clear();
      _quantityController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Donation submitted! Waiting for admin approval."),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload donations
      await _loadMyDonations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit donation: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
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
                  onPressed: _isSubmitting ? null : _submitDonation,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Donate"),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Approved Donations",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadMyDonations,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _myDonations.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("No approved donations yet."),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _myDonations.length,
                          itemBuilder: (context, index) {
                            final donation = _myDonations[index];
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

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}