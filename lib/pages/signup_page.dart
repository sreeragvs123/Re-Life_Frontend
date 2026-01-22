// lib/signup_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signup() {
    final name = _nameController.text.trim();
    final place = _placeController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || place.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("All fields are required");
      return;
    }

    var vBox = Hive.box('volunteersBox');
    if (vBox.containsKey(email)) {
      _showError("Email already registered");
      return;
    }

    vBox.put(email, {'name': name, 'place': place, 'password': password});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signup successful! Please login.")),
    );
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 64,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Volunteer Signup",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Place
                    TextField(
                      controller: _placeController,
                      decoration: InputDecoration(
                        labelText: "Place",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Signup",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Go back button
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.indigo),
                      label: const Text(
                        "Go Back",
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
