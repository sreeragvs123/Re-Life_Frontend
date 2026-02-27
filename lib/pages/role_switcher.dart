// lib/pages/role_switcher.dart
//
// Dev/testing tool — lets you switch between User/Volunteer/Admin homes.
// Reads the logged-in volunteer from Hive (after real login) so it works
// with actual registered accounts, not hardcoded test data.

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'user_home.dart';
import 'volunteer_home.dart';
import 'admin_home.dart';
import '../models/volunteer.dart';

class RoleSwitcher extends StatefulWidget {
  const RoleSwitcher({super.key});

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> {
  int _currentIndex = 0;

  late final List<Widget> _rolePages;

  @override
  void initState() {
    super.initState();

    // Build volunteer from Hive session (set at login) instead of hardcoded data
    final box   = Hive.box('authBox');
    final name  = box.get('name')  as String? ?? 'Test Volunteer';
    final place = box.get('place') as String? ?? 'Test Place';
    final email = box.get('email') as String? ?? 'volunteer@test.com';

    _rolePages = [
      const UserHome(),
      VolunteerHome(
        volunteer: Volunteer(
          name:     name,
          place:    place,
          email:    email,
          password: '',
        ),
      ),
      const AdminHome(),
    ];
  }

  final List<String> _titles = [
    'Disaster Management',
    'Disaster Management',
    'Disaster Management',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: const Color.fromARGB(255, 70, 70, 70),
      ),
      body: _rolePages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color.fromARGB(255, 70, 70, 70),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'User'),
          BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: 'Volunteer'),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}