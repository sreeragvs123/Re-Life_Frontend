// lib/pages/add_product_page.dart
//
// ⭐ POSTs a new ProductRequest to /api/products via ProductApi.
//    Returns true to the previous page so it can refresh the list.

import 'package:flutter/material.dart';
import '../api/product_api.dart';
import '../models/product_request.dart';

class AddProductPage extends StatefulWidget {
  final String requesterName;

  const AddProductPage({super.key, required this.requesterName});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedUrgency   = 'Medium';
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _submitting = true);

    try {
      await ProductApi.addProduct(ProductRequest(
        name: _nameController.text.trim(),
        quantity: int.parse(_quantityController.text.trim()),
        requester: widget.requesterName,
        urgency: _selectedUrgency,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Product request submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // ← signals success to ProductListPage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product Request'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Requester chip ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 16,
                        color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text('Requesting as: ${widget.requesterName}',
                        style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Product Name ───────────────────────────────────────────
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Enter product name'
                        : null,
              ),
              const SizedBox(height: 16),

              // ── Quantity ───────────────────────────────────────────────
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter quantity';
                  final qty = int.tryParse(v.trim());
                  if (qty == null || qty <= 0) return 'Enter a valid quantity';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Urgency ────────────────────────────────────────────────
              DropdownButtonFormField<String>(
                value: _selectedUrgency,
                decoration: InputDecoration(
                  labelText: 'Urgency',
                  prefixIcon: const Icon(Icons.priority_high),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: [
                  _urgencyItem('High',   Colors.red),
                  _urgencyItem('Medium', Colors.orange),
                  _urgencyItem('Low',    Colors.green),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedUrgency = v);
                },
              ),
              const SizedBox(height: 32),

              // ── Submit ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitting ? null : _submitForm,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Request',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _urgencyItem(String label, Color color) {
    return DropdownMenuItem(
      value: label,
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}