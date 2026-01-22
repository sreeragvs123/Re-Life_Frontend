// pages/product_list_page.dart
import 'package:flutter/material.dart';
import '../data/product_data.dart';
import '../models/product_request.dart';
import 'add_product_page.dart';

class ProductListPage extends StatefulWidget {
  final bool canAdd;
  final String requesterName;

  const ProductListPage({super.key, this.canAdd = false, this.requesterName = "Admin"});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {

  void _refreshList() {
    setState(() {}); // rebuild to reflect changes
  }

  @override
  Widget build(BuildContext context) {
    List<ProductRequest> high = productRequests.where((p) => p.urgency == "High").toList();
    List<ProductRequest> medium = productRequests.where((p) => p.urgency == "Medium").toList();
    List<ProductRequest> low = productRequests.where((p) => p.urgency == "Low").toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Required Products"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          if (high.isNotEmpty) _buildUrgencySection("High Urgency 🔴", high),
          if (medium.isNotEmpty) _buildUrgencySection("Medium Urgency 🟠", medium),
          if (low.isNotEmpty) _buildUrgencySection("Low Urgency 🟢", low),
        ],
      ),
      floatingActionButton: widget.canAdd
          ? FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProductPage(requesterName: widget.requesterName),
                  ),
                );
                _refreshList(); // refresh after adding new product
              },
            )
          : null,
    );
  }

  Widget _buildUrgencySection(String title, List<ProductRequest> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...requests.map((req) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(req.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Qty: ${req.quantity} • By: ${req.requester}"),
                leading: const Icon(Icons.shopping_bag, color: Colors.deepPurple),
              ),
            )),
      ],
    );
  }
}
