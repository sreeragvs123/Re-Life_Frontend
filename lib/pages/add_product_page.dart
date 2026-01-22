import 'package:flutter/material.dart';
import '../data/product_data.dart';
import '../models/product_request.dart';
import '../utils/validators.dart';

class AddProductPage extends StatefulWidget {
  final String requesterName; // Pass Admin or Volunteer name

  const AddProductPage({super.key, required this.requesterName});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String selectedUrgency = "Medium";
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Add to list
      productRequests.add(ProductRequest(
        name: nameController.text,
        quantity: int.tryParse(quantityController.text) ?? 0,
        requester: widget.requesterName,
        urgency: selectedUrgency,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Product request added!")),
      );

      Navigator.pop(context);
    } else {
      setState(() {
        _autoValidate = AutovalidateMode.onUserInteraction; // start live validation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product Request")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter quantity";
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return "Enter valid quantity";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedUrgency,
                decoration: const InputDecoration(
                  labelText: "Urgency",
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: ["High", "Medium", "Low"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedUrgency = value);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Submit Request"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
