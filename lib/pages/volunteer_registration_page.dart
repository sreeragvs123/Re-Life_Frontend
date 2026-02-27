// lib/pages/volunteer_registration_page.dart
//
// ⭐ Registers a new VOLUNTEER via /api/auth/signUp (role=VOLUNTEER)
//    AND saves to Hive volunteersBox so AdminVolunteerListPage
//    can group them by place without an extra API call.
//
// Accessible from UserHome → "Volunteer Registration" card.

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../utils/validators.dart';
import '../api/auth_api.dart';
import '../models/auth_models.dart';
import 'login_page.dart';

class VolunteerRegistrationPage extends StatefulWidget {
  const VolunteerRegistrationPage({super.key});

  @override
  State<VolunteerRegistrationPage> createState() =>
      _VolunteerRegistrationPageState();
}

class _VolunteerRegistrationPageState
    extends State<VolunteerRegistrationPage> {
  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _placeController  = TextEditingController();
  final _emailController  = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading         = false;
  bool _obscurePassword   = true;

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerVolunteer() async {
    if (!_formKey.currentState!.validate()) return;

    final name     = _nameController.text.trim();
    final place    = _placeController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      // ── 1. Register via API (role = VOLUNTEER) ─────────────────────────
      await AuthApi.signUp(SignUpRequest(
        name:     name,
        email:    email,
        password: password,
        place:    place,
        role:     'VOLUNTEER',
      ));

      // ── 2. Mirror to Hive so AdminVolunteerListPage can group by place ─
      final vBox = Hive.box('volunteersBox');
      await vBox.put(email, {
        'name':     name,
        'place':    place,
        'email':    email,
        'password': '', // never store plain password after API registration
      });

      if (!mounted) return;
      _showMessage('Registration successful! Please login.');

      _nameController.clear();
      _placeController.clear();
      _emailController.clear();
      _passwordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.person_add,
                      size: 64, color: Colors.indigo),
                  const SizedBox(height: 16),
                  Text(
                    'Register as Volunteer',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Name'),
                    validator: (val) => Validators.validate(
                        value: val ?? '', type: 'name'),
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),

                  // Place
                  TextFormField(
                    controller: _placeController,
                    decoration:
                        const InputDecoration(labelText: 'Place / Location'),
                    validator: (val) => Validators.validate(
                        value: val ?? '', type: 'place'),
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(labelText: 'Email'),
                    validator: (val) => Validators.validate(
                        value: val ?? '', type: 'email'),
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) => Validators.validate(
                        value: val ?? '',
                        type: 'password',
                        minLength: 5),
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerVolunteer,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Register',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                    ),
                    icon: const Icon(Icons.login, color: Colors.indigo),
                    label: const Text(
                      'Already have an account? Login',
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