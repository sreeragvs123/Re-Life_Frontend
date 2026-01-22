// lib/volunteer_registration_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart';
import '../../utils/validators.dart';

class VolunteerRegistrationPage extends StatefulWidget {
  const VolunteerRegistrationPage({super.key});

  @override
  State<VolunteerRegistrationPage> createState() =>
      _VolunteerRegistrationPageState();
}

class _VolunteerRegistrationPageState extends State<VolunteerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _registerVolunteer() async {
    if (!_formKey.currentState!.validate()) return; // validate first

    final name = _nameController.text.trim();
    final place = _placeController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    var volunteersBox = Hive.box('volunteersBox');

    // Check duplicate email
    if (volunteersBox.containsKey(email)) {
      _showMessage("Email already registered");
      return;
    }

    // Save volunteer in Hive
    await volunteersBox.put(email, {
      'name': name,
      'place': place,
      'email': email,
      'password': password,
    });

    _showMessage("Registration successful! Please login.");

    // Clear input fields
    _nameController.clear();
    _placeController.clear();
    _emailController.clear();
    _passwordController.clear();

    // Navigate to Login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volunteer Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.person_add, size: 64, color: Colors.indigo),
                  const SizedBox(height: 16),
                  Text(
                    "Register as Volunteer",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator: (val) => Validators.validate(value: val ?? "", type: "name"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),

                  // Place
                  TextFormField(
                    controller: _placeController,
                    decoration: const InputDecoration(labelText: "Place"),
                    validator: (val) => Validators.validate(value: val ?? "", type: "place"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (val) => Validators.validate(value: val ?? "", type: "email"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (val) => Validators.validate(value: val ?? "", type: "password", minLength: 5),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerVolunteer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Register", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    icon: const Icon(Icons.login, color: Colors.indigo),
                    label: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
