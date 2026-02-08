import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../api/donation_api.dart';

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

  List<Donation> _approvedDonations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApprovedDonations();
  }

  Future<void> _loadApprovedDonations() async {
    setState(() => _isLoading = true);
    try {
      final donations = await DonationApi.getApprovedDonations();
      setState(() {
        _approvedDonations = donations;
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

  Future<void> _updateStatus(Donation donation, String newStatus) async {
    try {
      final updatedDonation = await DonationApi.updateDonationStatus(
        donation.id!,
        newStatus,
      );

      // Update local state
      setState(() {
        final index = _approvedDonations.indexWhere((d) => d.id == donation.id);
        if (index != -1) {
          _approvedDonations[index] = updatedDonation;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status updated to: $newStatus"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update status: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _statusColor(String status) {
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

  IconData _statusIcon(String status) {
    switch (status) {
      case "Pending":
        return Icons.pending;
      case "Approved":
        return Icons.check_circle;
      case "On the way":
        return Icons.local_shipping;
      case "Delivered":
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer: Update Status"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApprovedDonations,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _approvedDonations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No approved donations",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _approvedDonations.length,
                    itemBuilder: (context, index) {
                      final donation = _approvedDonations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(_statusIcon(donation.status),
                                      color: _statusColor(donation.status)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      donation.item,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(Icons.numbers, "Quantity", "${donation.quantity}"),
                              _buildInfoRow(Icons.person, "Donor", donation.donorName),
                              _buildInfoRow(Icons.phone, "Contact", donation.contact),
                              _buildInfoRow(Icons.location_on, "Address", donation.address),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(donation.status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _statusIcon(donation.status),
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          donation.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: donation.status,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        items: statusOptions
                                            .map((e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e),
                                                ))
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null && val != donation.status) {
                                            _updateStatus(donation, val);
                                          }
                                        },
                                      ),
                                    ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}