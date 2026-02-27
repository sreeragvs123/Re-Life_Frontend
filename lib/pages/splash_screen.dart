// lib/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'user_home.dart';
import 'admin_home.dart';
import 'volunteer_home.dart';
import 'login_page.dart';
import '../models/volunteer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Wait for the first frame to be rendered BEFORE starting the timer.
    // This guarantees Navigator is ready when we call pushReplacement.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), _navigateNext);
    });
  }

  void _navigateNext() {
    if (!mounted) return;

    final authBox    = Hive.box('authBox');
    final isLoggedIn = authBox.get('isLoggedIn', defaultValue: false) as bool;
    final role       = authBox.get('role') as String?;   // null = not logged in

    Widget nextPage;

    if (isLoggedIn && role == 'ADMIN') {
      nextPage = const AdminHome();

    } else if (isLoggedIn && role == 'VOLUNTEER') {
      final email = authBox.get('email') as String? ?? '';
      final name  = authBox.get('name')  as String? ?? '';
      final place = authBox.get('place') as String? ?? '';
      nextPage = VolunteerHome(
        volunteer: Volunteer(
          name:     name,
          place:    place,
          email:    email,
          password: '',
        ),
      );

    } else if (isLoggedIn && role == 'USER') {
      nextPage = const UserHome();

    } else {
      // Not logged in → always go to LoginPage
      nextPage = const LoginPage();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 300),
              const SizedBox(height: 20),
              const Text(
                'RE-LIFE',
                style: TextStyle(
                  fontFamily: 'Impact',
                  fontSize: 36,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // Progress indicator so the user knows the app is loading
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}