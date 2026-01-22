import 'package:flutter/material.dart';
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

  // Example volunteer for testing
  final Volunteer testVolunteer = Volunteer(
  name: "Amit Sharma",
  place: "Delhi",
  email: "amit.sharma@example.com",
  password: "123456",
);


  late final List<Widget> _rolePages;

  @override
  void initState() {
    super.initState();
    _rolePages = [
      const UserHome(),
      VolunteerHome(volunteer: testVolunteer), // ✅ pass volunteer here
      const AdminHome(),
    ];
  }

  final List<String> _titles = [
    "Disaster Management",
    "Disaster Management",
    "Disaster Management",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" ${_titles[_currentIndex]}"),
        backgroundColor: const Color.fromARGB(255, 70, 70, 70),
      ),
      body: _rolePages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
         backgroundColor: const Color.fromARGB(255, 70, 70, 70),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "User2",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: "Volunteer2",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: "Admin2",
          ),
        ],
      ),
    );
  }
}
