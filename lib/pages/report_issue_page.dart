import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/issue_model.dart';
import '../api/issue_api.dart';           // ⭐ NEW
import '../utils/validators.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String name = '';
  String email = '';
  String? phone;
  String title = '';
  String description = '';
  String? category;
  String? priority;
  String? location;
  Uint8List? attachment;

  bool _isSubmitting = false;
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  final List<String> categories = ['Bug', 'Feature Request', 'UI Issue', 'Other'];
  final List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4', 'mov'],
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() => attachment = result.files.single.bytes);
    }
  }

  Future<void> captureFromCamera() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() => attachment = result.files.single.bytes);
      }
    } else {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (file != null) {
        setState(() async => attachment = await file.readAsBytes());
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    try {
      await IssueApi.createIssue(
        Issue(
          name: name,
          email: email,
          phone: phone,
          title: title,
          description: description,
          category: category,
          priority: priority,
          location: location,
          attachment: attachment,
          date: DateTime.now(),
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue reported successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem,
                        color: Colors.blue, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please provide all details clearly so we can resolve the issue faster.',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: Column(
                    children: [
                      _field('Name', Icons.person, 'name',
                          onSaved: (v) => name = v!.trim()),
                      const SizedBox(height: 15),
                      _field('Email', Icons.email, 'email',
                          onSaved: (v) => email = v!.trim()),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v != null && v.isNotEmpty
                            ? Validators.validate(value: v, type: 'mobile')
                            : null,
                        onSaved: (v) => phone = v,
                      ),
                      const SizedBox(height: 15),
                      _field('Title', Icons.title, 'place',
                          minLength: 3, onSaved: (v) => title = v!.trim()),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (v) => Validators.validate(
                            value: v ?? '', type: 'place', minLength: 5),
                        onSaved: (v) => description = v!.trim(),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => category = v),
                        onSaved: (v) => category = v,
                        validator: (v) =>
                            v == null ? 'Select category' : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        items: priorities
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) => setState(() => priority = v),
                        onSaved: (v) => priority = v,
                        validator: (v) =>
                            v == null ? 'Select priority' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Location (optional)',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v != null && v.isNotEmpty
                            ? Validators.validate(value: v, type: 'place')
                            : null,
                        onSaved: (v) => location = v,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Attach File'),
                            onPressed: pickFile,
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Capture'),
                            onPressed: captureFromCamera,
                          ),
                        ],
                      ),
                      if (attachment != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(attachment!,
                                fit: BoxFit.cover),
                          ),
                        ),
                      ],
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitForm,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          label: Text(_isSubmitting
                              ? 'Submitting...'
                              : 'Submit Issue',
                              style: const TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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

  // Helper to reduce repetition for simple text fields
  Widget _field(String label, IconData icon, String type,
      {int? minLength, required FormFieldSetter<String> onSaved}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => Validators.validate(
          value: v ?? '', type: type, minLength: minLength),
      onSaved: onSaved,
    );
  }
}