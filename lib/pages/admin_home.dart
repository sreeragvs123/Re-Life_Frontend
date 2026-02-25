// lib/admin_home.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'admin_report_page.dart';
import 'admin_video_approval_page.dart';
import '../data/report_data.dart';
import 'volunteer_report_page.dart';

import 'shelter_list_page.dart';
import 'product_list_page.dart';
import 'admin_missing_person_page.dart';
import 'admin_donation_page.dart';
import '../api/donation_api.dart';           // ⭐ Use API for donation count
import 'video_gallery_page.dart';
import 'issue_list_page.dart';
import 'admin_volunteer_list_page.dart';
import 'evacuation_map_page.dart';           // ⭐ Map page
import 'user_home.dart';
import 'volunteer_home.dart';
import '../models/volunteer.dart';
import '../widgets/function_card.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  bool hasNewIssue = true;
  late AnimationController _controller;
  int totalDonations = 0;               // ⭐ Now loaded from API

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..forward();
    _loadDonationCount();               // ⭐ Load from backend
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ⭐ NEW: Load donation count from API (mirrors UserHome pattern)
  Future<void> _loadDonationCount() async {
    try {
      final donations = await DonationApi.getApprovedDonations();
      if (mounted) {
        setState(() {
          totalDonations = donations.fold(0, (sum, d) => sum + d.quantity);
        });
      }
    } catch (_) {
      if (mounted) setState(() => totalDonations = 0);
    }
  }

  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: const Duration(seconds: 5),
      onEnd: () => setState(() {}),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blueAccent]..shuffle(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  void _signOut() {
    var box = Hive.box('authBox');
    box.put('isLoggedIn', false);
    box.put('role', "USER");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UserHome()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        shadowColor: Colors.deepPurpleAccent,
        elevation: 8,
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showFunctionsDialog(context),
          ),
          TextButton(
            onPressed: _signOut,
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.switch_account, color: Colors.white),
            onSelected: (value) => _handleRoleSwitch(value),
            itemBuilder: (context) {
              var role = Hive.box('authBox').get('role');
              List<PopupMenuEntry<String>> items = [];
              if (role == "ADMIN") {
                items.add(const PopupMenuItem(
                    value: "admin", child: Text("Admin Home")));
              }
              items.add(const PopupMenuItem(
                  value: "user", child: Text("User Home")));
              items.add(const PopupMenuItem(
                  value: "volunteer", child: Text("Volunteer Home")));
              return items;
            },
          )
        ],
      ),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                // ⭐ UPDATED: "Evacuation Map" replaces the old static AddShelterRoutePage card
                //   Admin opens map with isAdmin:true — can add/delete shelters from within
                _buildAnimatedCard(
                  0,
                  _buildHoverCard(FunctionCard(
                    title: "Evacuation Map",
                    icon: Icons.map,
                    color: Colors.white.withOpacity(0.4),
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EvacuationMapPage(isAdmin: true),
                      ),
                    ),
                  )),
                ),
                // Manage Shelters
                _buildAnimatedCard(
                  1,
                  _buildHoverCard(FunctionCard(
                    title: "Manage Shelters",
                    icon: Icons.home_work,
                    color: Colors.white.withOpacity(0.4),
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ShelterListPage(isAdmin: true)),
                    ),
                  )),
                ),
                // Volunteers & Tasks
                _buildAnimatedCard(
                  2,
                  _buildHoverCard(FunctionCard(
                    title: "Volunteers & Tasks",
                    icon: Icons.group,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.4),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminVolunteerListPage()),
                    ),
                  )),
                ),
                // Required Products
                _buildAnimatedCard(
                  3,
                  _buildHoverCard(FunctionCard(
                    title: "Required Products",
                    icon: Icons.shopping_cart,
                    color: Colors.white.withOpacity(0.4),
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProductListPage(canAdd: true)),
                    ),
                  )),
                ),
                // Missing Persons
                _buildAnimatedCard(
                  4,
                  _buildHoverCard(FunctionCard(
                    title: "Missing Persons",
                    icon: Icons.person,
                    color: Colors.white.withOpacity(0.4),
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminMissingPersonPage()),
                    ),
                  )),
                ),
                // Reported Issues
                _buildAnimatedCard(
                  5,
                  _buildHoverCard(FunctionCard(
                    title: "Reported Issues",
                    icon: Icons.report_problem,
                    color: Colors.white.withOpacity(0.4),
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    badge: hasNewIssue
                        ? Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() => hasNewIssue = false);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const IssueListPage(role: "Admin")));
                    },
                  )),
                ),
                // Videos
                _buildAnimatedCard(
                  6,
                  _buildHoverCard(FunctionCard(
                    title: "Videos",
                    icon: Icons.video_library,
                    color: Colors.white.withOpacity(0.4),
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminVideoApprovalPage()),
                    ),
                  )),
                ),
                // Donations — ⭐ count now from API
                _buildAnimatedCard(
                  7,
                  _buildHoverCard(FunctionCard(
                    title: "Donations ($totalDonations)",
                    icon: Icons.volunteer_activism,
                    color: Colors.white.withOpacity(0.35),
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDonationPage(),
                        ),
                      );
                      _loadDonationCount(); // Refresh count on return
                    },
                  )),
                ),
                // Volunteer Reports
                _buildAnimatedCard(
                  8,
                  _buildHoverCard(FunctionCard(
                    title: "Volunteer Reports (${reports.length})",
                    icon: Icons.report,
                    color: Colors.white.withOpacity(0.35),
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminReportPage(
                            volunteerName: AdminVolunteerListPage(),
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoverCard(Widget child) {
    return StatefulBuilder(builder: (context, setHover) {
      bool hovering = false;
      return MouseRegion(
        onEnter: (_) => setHover(() => hovering = true),
        onExit: (_) => setHover(() => hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: hovering
              ? (Matrix4.identity()
                ..translate(0, -8, 0)
                ..scale(1.03))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: hovering
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: child,
        ),
      );
    });
  }

  Widget _buildAnimatedCard(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.1, 1, curve: Curves.easeOutBack),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                .animate(animation),
        child: child,
      ),
    );
  }

  void _showFunctionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        title: const Text("Quick Access"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // ⭐ Updated: now navigates to EvacuationMapPage
              _buildFunctionItem(context, "Evacuation Map", Icons.map, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const EvacuationMapPage(isAdmin: true)));
              }),
              _buildFunctionItem(context, "Manage Shelters", Icons.home_work,
                  () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ShelterListPage(isAdmin: true)));
              }),
              _buildFunctionItem(context, "Volunteers & Tasks", Icons.group,
                  () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminVolunteerListPage()));
              }),
              _buildFunctionItem(
                  context, "Required Products", Icons.shopping_cart, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProductListPage(canAdd: true)));
              }),
              _buildFunctionItem(context, "Missing Persons", Icons.person, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminMissingPersonPage()));
              }),
              _buildFunctionItem(
                  context, "Donations ($totalDonations)", Icons.list, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDonationPage()),
                );
              }),
              _buildFunctionItem(
                  context, "Reported Issues", Icons.report_problem, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const IssueListPage(role: "Admin")));
              }),
              _buildFunctionItem(context, "Videos", Icons.video_library, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VideoGalleryPage()));
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _buildFunctionItem(BuildContext context, String title, IconData icon,
      VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _handleRoleSwitch(String value) {
    var box = Hive.box('authBox');
    var role = box.get('role');
    var email = box.get('email');

    if (value == "user") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHome()),
      );
    } else if (value == "volunteer") {
      Volunteer volunteerToOpen;
      if (role == "VOLUNTEER") {
        var volunteersBox = Hive.box('volunteersBox');
        if (email != null && volunteersBox.containsKey(email)) {
          var data = volunteersBox.get(email);
          volunteerToOpen = Volunteer(
            name: data['name'],
            place: data['place'],
            email: email,
            password: data['password'],
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Volunteer data not found!")));
          return;
        }
      } else {
        volunteerToOpen = Volunteer(
          name: "Admin Volunteer",
          place: "Admin Center",
          email: "admin@admin.com",
          password: "admin123",
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => VolunteerHome(volunteer: volunteerToOpen)),
      );
    } else if (value == "admin") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Already on Admin Home")));
    }
  }
}