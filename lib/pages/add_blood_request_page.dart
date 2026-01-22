import 'package:flutter/material.dart';
import '../models/blood_request.dart';
import '../api/blood_api.dart';
import '../utils/validators.dart';

class AddBloodRequestPage extends StatefulWidget {
  const AddBloodRequestPage({super.key});

  @override
  State<AddBloodRequestPage> createState() => _AddBloodRequestPageState();
}

class _AddBloodRequestPageState extends State<AddBloodRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = BloodApi();

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedBloodGroup;

  final _bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = BloodRequest(
      name: _nameController.text.trim(),
      bloodGroup: _selectedBloodGroup!,
      contact: _contactController.text.trim(),
      city: _cityController.text.trim(),
    );

    await _api.create(request);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Blood Request")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                validator: (v) => Validators.validate(value: v ?? '', type: "name"),
                decoration: const InputDecoration(labelText: "Name"),
              ),
              DropdownButtonFormField(
                value: _selectedBloodGroup,
                items: _bloodGroups
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
                validator: (v) => v == null ? "Select blood group" : null,
                decoration: const InputDecoration(labelText: "Blood Group"),
              ),
              TextFormField(
                controller: _contactController,
                validator: (v) => Validators.validate(value: v ?? '', type: "mobile"),
                decoration: const InputDecoration(labelText: "Contact"),
              ),
              TextFormField(
                controller: _cityController,
                validator: (v) => Validators.validate(value: v ?? '', type: "place"),
                decoration: const InputDecoration(labelText: "City"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
