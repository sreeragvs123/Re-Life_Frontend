import 'package:flutter/material.dart';
import '../models/missing_person.dart';
import '../../utils/validators.dart';

class ReportMissingPersonPage extends StatefulWidget {
  const ReportMissingPersonPage({super.key});

  @override
  State<ReportMissingPersonPage> createState() =>
      _ReportMissingPersonPageState();
}

class _ReportMissingPersonPageState extends State<ReportMissingPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _lastSeenController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _familyContactController = TextEditingController();

  // Controls when to show validation errors
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, create MissingPerson object
      final newPerson = MissingPerson(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        lastSeen: _lastSeenController.text,
        description: _descriptionController.text,
        familyName: _familyNameController.text,
        familyContact: _familyContactController.text,
      );
      Navigator.pop(context, newPerson);
    } else {
      // Show errors after first submit
      setState(() {
        _autoValidate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Missing Person"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem,
                        size: 40, color: Colors.redAccent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Please provide details carefully.\nThis will help in locating the missing person.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            Validators.validate(value: v ?? "", type: "name"),
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Age",
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final age = int.tryParse(v ?? "");
                          if (age == null || age <= 0) return "Enter valid age";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _lastSeenController,
                        decoration: const InputDecoration(
                          labelText: "Last Seen Location",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            Validators.validate(value: v ?? "", type: "place"),
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? "Enter description" : null,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _familyNameController,
                        decoration: const InputDecoration(
                          labelText: "Family Name",
                          prefixIcon: Icon(Icons.group),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            Validators.validate(value: v ?? "", type: "name"),
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _familyContactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Family Contact",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            Validators.validate(value: v ?? "", type: "mobile"),
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            "Submit Report",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}