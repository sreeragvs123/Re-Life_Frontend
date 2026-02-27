// lib/pages/product_list_page.dart
//
// ⭐ Fully API-driven. Loads products from /api/products via ProductApi.
//    canAdd=true  → shows FAB for Admin / Volunteer
//    canAdd=false → read-only for Users

import 'package:flutter/material.dart';
import '../api/product_api.dart';
import '../models/product_request.dart';
import 'add_product_page.dart';

class ProductListPage extends StatefulWidget {
  final bool canAdd;
  final String requesterName;

  const ProductListPage({
    super.key,
    this.canAdd = false,
    this.requesterName = 'Admin',
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductRequest> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await ProductApi.getAllProducts();
      if (mounted) setState(() => _products = products);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteProduct(ProductRequest product) async {
    if (product.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Remove "${product.name}" from the list?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ProductApi.deleteProduct(product.id!);
        _fetchProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Required Products'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: widget.canAdd
          ? FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
              onPressed: () async {
                final added = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProductPage(
                        requesterName: widget.requesterName),
                  ),
                );
                if (added == true) _fetchProducts();
              },
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _fetchProducts, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_products.isEmpty) {
      return const Center(
        child: Text('No product requests yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    final high   = _products.where((p) => p.urgency == 'High').toList();
    final medium = _products.where((p) => p.urgency == 'Medium').toList();
    final low    = _products.where((p) => p.urgency == 'Low').toList();

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: ListView(
        children: [
          if (high.isNotEmpty)   _buildSection('🔴 High Urgency', high,   Colors.red.shade50),
          if (medium.isNotEmpty) _buildSection('🟠 Medium Urgency', medium, Colors.orange.shade50),
          if (low.isNotEmpty)    _buildSection('🟢 Low Urgency', low,    Colors.green.shade50),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<ProductRequest> items, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...items.map((req) => Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: const Icon(Icons.shopping_bag,
                      color: Colors.deepPurple),
                ),
                title: Text(req.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Qty: ${req.quantity}  •  By: ${req.requester}'),
                trailing: widget.canAdd
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _deleteProduct(req),
                        tooltip: 'Delete',
                      )
                    : null,
              ),
            )),
      ],
    );
  }
}