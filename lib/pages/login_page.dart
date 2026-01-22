import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../utils/validators.dart';
import 'admin_home.dart';
import 'volunteer_home.dart';
import '../models/volunteer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedRole = "ADMIN"; // Default role

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    var box = Hive.box('authBox');

    if (_selectedRole == "ADMIN") {
      if (email == "admin@admin.com" && password == "admin123") {
        box.put('isLoggedIn', true);
        box.put('role', "ADMIN");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminHome()),
          (route) => false,
        );
      } else {
        _showError("Invalid Admin credentials");
      }
    } else if (_selectedRole == "VOLUNTEER") {
      var volunteersBox = Hive.box('volunteersBox');
      if (volunteersBox.containsKey(email) &&
          volunteersBox.get(email)['password'] == password) {
        box.put('isLoggedIn', true);
        box.put('role', "VOLUNTEER");
        box.put('email', email);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => VolunteerHome(
              volunteer: Volunteer(
                name: volunteersBox.get(email)['name'],
                place: volunteersBox.get(email)['place'],
                email: email,
                password: volunteersBox.get(email)['password'],
              ),
            ),
          ),
          (route) => false,
        );
      } else {
        _showError("Invalid Volunteer credentials");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
                  borderRadius: BorderRadius.circular(24)),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Disaster Relief Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Role Selector
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: const [
                          DropdownMenuItem(
                              value: "ADMIN", child: Text("Admin")),
                          DropdownMenuItem(
                              value: "VOLUNTEER", child: Text("Volunteer")),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedRole = value);
                        },
                        decoration: InputDecoration(
                          labelText: "Select Role",
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
                      TextFormField(
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
                        validator: (val) =>
                            Validators.validate(value: val ?? "", type: "email"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
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
                        validator: (val) =>
                            Validators.validate(value: val ?? "", type: "password", minLength: 5),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color.fromARGB(255, 79, 139, 218),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Go Back Button
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
      ),
    );
  }
}