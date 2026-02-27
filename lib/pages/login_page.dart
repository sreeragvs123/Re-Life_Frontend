// lib/pages/login_page.dart
//
// Two-tab login:
//   • User tab           → self-registered users (Role.USER) → UserHome
//   • Volunteer/Admin tab → volunteers + admin → VolunteerHome / AdminHome
//
// Admin enters email/password just like any other user — the role comes
// back from the JWT response, no special hardcoded credentials needed.

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../utils/validators.dart';
import '../api/auth_api.dart';
import '../models/auth_models.dart';
import '../models/volunteer.dart';
import 'admin_home.dart';
import 'volunteer_home.dart';
import 'user_home.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Tracks which tab: "USER" or "VOLUNTEER_ADMIN"
  String _selectedMode = "VOLUNTEER_ADMIN";

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _isLoading           = false;
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final resp = await AuthApi.login(LoginRequest(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ));

      if (!mounted) return;

      // Guard: USER tab should not log in as VOLUNTEER/ADMIN and vice versa
      if (_selectedMode == 'USER' && resp.role != 'USER') {
        _showError('This account is not a User account. Use the Volunteer/Admin tab.');
        return;
      }
      if (_selectedMode == 'VOLUNTEER_ADMIN' && resp.role == 'USER') {
        _showError('This is a User account. Use the User tab.');
        return;
      }

      _navigateHome(resp);
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateHome(LoginResponse resp) {
    Widget home;

    switch (resp.role) {
      case 'ADMIN':
        home = const AdminHome();
        break;
      case 'VOLUNTEER':
        // Save to volunteersBox so AdminVolunteerListPage can see them
        final vBox = Hive.box('volunteersBox');
        vBox.put(resp.email, {
          'name':     resp.name,
          'place':    resp.place ?? '',
          'email':    resp.email,
          'password': '', // never store plain password — empty sentinel
        });
        home = VolunteerHome(
          volunteer: Volunteer(
            name:     resp.name,
            place:    resp.place ?? '',
            email:    resp.email,
            password: '',
          ),
        );
        break;
      default: // USER
        home = const UserHome();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => home),
      (route) => false,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
      ),
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
                      const Icon(Icons.lock_outline,
                          size: 64, color: Colors.indigo),
                      const SizedBox(height: 12),
                      Text(
                        'Disaster Relief Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Role tab selector ──────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTabButton('USER', 'User',
                                Icons.person),
                            _buildTabButton('VOLUNTEER_ADMIN',
                                'Volunteer / Admin',
                                Icons.badge),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Hint text below tab
                      Text(
                        _selectedMode == 'VOLUNTEER_ADMIN'
                            ? 'Admin credentials work here too'
                            : 'New user? Sign up below',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),

                      // ── Email ──────────────────────────────────────────
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) => Validators.validate(
                            value: val ?? '', type: 'email'),
                        autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 16),

                      // ── Password ───────────────────────────────────────
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
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

                      // ── Login button ───────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                const Color.fromARGB(255, 79, 139, 218),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Sign up link (User tab only) ───────────────────
                      if (_selectedMode == 'USER')
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupPage()),
                          ),
                          icon: const Icon(Icons.person_add,
                              color: Colors.indigo),
                          label: const Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),

                      // ── Volunteer registration note (Volunteer tab) ────
                      if (_selectedMode == 'VOLUNTEER_ADMIN')
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Volunteers register via the Volunteer Registration form on the User Home screen.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600),
                          ),
                        ),

                      // ── Go back ────────────────────────────────────────
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.indigo),
                        label: const Text('Go Back',
                            style: TextStyle(color: Colors.indigo)),
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

  Widget _buildTabButton(String mode, String label, IconData icon) {
    final selected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}