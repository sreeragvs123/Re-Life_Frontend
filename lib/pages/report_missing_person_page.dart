import 'package:flutter/material.dart';
import '../models/missing_person.dart';
import '../../utils/validators.dart';
// ⭐ ADDED: Import API service
import '../api/missing_person_api.dart';

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
  
  // ⭐ ADDED: Loading state and API instance
  bool _isSubmitting = false;
  final MissingPersonApi _api = MissingPersonApi();

  // ⭐ EDITED: Submit now saves to backend
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {
        // Create MissingPerson object
        final newPerson = MissingPerson(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          age: int.tryParse(_ageController.text) ?? 0,
          lastSeen: _lastSeenController.text,
          description: _descriptionController.text,
          familyName: _familyNameController.text,
          familyContact: _familyContactController.text,
        );
        
        // ⭐ ADDED: Save to backend
        await MissingPersonApi.create(newPerson);
        
        setState(() => _isSubmitting = false);
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Missing person reported successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Return true to indicate success
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() => _isSubmitting = false);
        
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error reporting missing person: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
                          // ⭐ EDITED: Disable button while submitting
                          onPressed: _isSubmitting ? null : _submit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isSubmitting ? "Submitting..." : "Submit Report",
                            style: const TextStyle(fontSize: 16),
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
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _lastSeenController.dispose();
    _descriptionController.dispose();
    _familyNameController.dispose();
    _familyContactController.dispose();
    super.dispose();
  }
}