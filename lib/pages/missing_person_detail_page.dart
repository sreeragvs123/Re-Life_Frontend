import 'package:flutter/material.dart';
import '../models/missing_person.dart';
import '../services/missing_person_api.dart';
import '../utils/validators.dart';

class ReportMissingPersonPage extends StatefulWidget {
  const ReportMissingPersonPage({super.key});

  @override
  State<ReportMissingPersonPage> createState() =>
      _ReportMissingPersonPageState();
}

class _ReportMissingPersonPageState
    extends State<ReportMissingPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = MissingPersonApi();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lastSeenController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _familyContactController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final person = MissingPerson(
      id: 0, // backend generates ID
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      description: _descriptionController.text.trim(),
      lastSeen: _lastSeenController.text.trim(),
      familyName: _familyNameController.text.trim(),
      familyContact: _familyContactController.text.trim(),
      isFound: false,
    );

    await _api.create(person);

    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Missing Person")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                validator: (v) =>
                    Validators.validate(value: v ?? '', type: "name"),
                decoration: const InputDecoration(labelText: "Person Name"),
              ),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    Validators.validate(value: v ?? '', type: "number"),
                decoration: const InputDecoration(labelText: "Age"),
              ),
              TextFormField(
                controller: _descriptionController,
                validator: (v) =>
                    Validators.validate(value: v ?? '', type: "text"),
                decoration:
                    const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: _lastSeenController,
                validator: (v) =>
                    Validators.validate(value: v ?? '', type: "place"),
                decoration:
                    const InputDecoration(labelText: "Last Seen Location"),
              ),
              TextFormField(
                controller: _familyNameController,
                validator: (v) =>
                    Validators.validate(value: v ?? '', type: "name"),
                decoration:
                    const InputDecoration(labelText: "Family Member Name"),
              ),
              TextFormField(
                controller: _familyContactController,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    Validators.validate(value: v ?? '', type: "mobile"),
                decoration:
                    const InputDecoration(labelText: "Family Contact"),
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
