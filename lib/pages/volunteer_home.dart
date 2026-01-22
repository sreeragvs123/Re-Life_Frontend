import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'volunteer_blood_page.dart';
import 'volunteer_donation_page.dart';
import 'volunteer_report_page.dart';
import 'volunteer_video_page.dart';

import '../widgets/function_card.dart';

import 'product_list_page.dart';
import 'missing_person_list_page.dart';
import '../data/missing_person_data.dart';
import 'volunteer_donation_page.dart';
import '../data/donation_data.dart';
import 'video_gallery_page.dart';
import 'issue_list_page.dart';
import 'volunteer_group_page.dart';
import '../models/volunteer.dart';
import '../pages/user_home.dart';
import '../pages/admin_home.dart';

// ✅ Hover wrapper (reusable)
class HoverCard extends StatefulWidget {
  final Widget child;
  const HoverCard({super.key, required this.child});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
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
                  ),
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

class VolunteerHome extends StatefulWidget {
  final Volunteer? volunteer; // Optional volunteer info
  const VolunteerHome({super.key, this.volunteer});

  @override
  State<VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome>
    with SingleTickerProviderStateMixin {
  bool hasNewIssue = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔹 Animated gradient background
Widget _buildAnimatedBackground() {
  return AnimatedContainer(
    duration: const Duration(seconds: 5),
    onEnd: () {
      setState(() {}); // triggers rebuild for gradient loop
    },
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white,
          Colors.blueAccent,
        ]..shuffle(), // shuffle for subtle animation
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
    box.delete('email');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const UserHome()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalDonations = donationsList.fold(0, (sum, d) => sum + d.quantity);
    final volunteerName = widget.volunteer?.name ?? "Guest Volunteer";
    final volunteerPlace = widget.volunteer?.place ?? "Unknown Place";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        shadowColor: Colors.deepPurpleAccent,
        elevation: 8,
        title: Text("Volunteer Dashboard ($volunteerName)",
                    style: GoogleFonts.bebasNeue(
                    fontSize: 28,
                    letterSpacing: 1.2,
                    color: Colors.white,
                    
          ),
        ),
        actions: [
          // ✅ Role dropdown menu
          Builder(
            builder: (context) {
              var box = Hive.box('authBox');
              String? role = box.get('role');

              if (role == "ADMIN") {
                // Admin can go to AdminHome, UserHome, and VolunteerHome (as special volunteer)
                return _roleSwitcher(context, ["admin", "user", "volunteer"]);
              } else if (role == "VOLUNTEER") {
                // Volunteer can go to UserHome or VolunteerHome (their real data)
                return _roleSwitcher(context, ["user", "volunteer"]);
              }
              return const SizedBox(); // Guest / no role: nothing
            },
          ),

          // ✅ Sign Out
          TextButton(
            onPressed: _signOut,
            child:
                const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),

          // Menu button
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showFunctionsDialog(context),
          ),
        ],
      ),
body: Stack(
  children: [
    // 🔹 Animated gradient
    Positioned.fill(child: _buildAnimatedBackground()),

    // 🔹 Optional dark overlay for readability


    // 🔹 Dashboard Grid
    Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
              children: [
                _buildAnimatedCard(
                  0,
                  HoverCard(
                    child: FunctionCard(
                      title: "Required Products",
                      icon: Icons.shopping_cart,
                      color: Colors.white.withOpacity(0.35),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductListPage(canAdd: true)),
                      ),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  1,
                  HoverCard(
                    child: FunctionCard(
                      title: "Missing Persons",
                      icon: Icons.person_search,
                      color: Colors.white.withOpacity(0.35),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MissingPersonListPage(
                              persons: sampleMissingPersons),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  2,
                  HoverCard(
                    child: FunctionCard(
                      title: "Reported Issues",
                      icon: Icons.report_problem,
                      color: Colors.white.withOpacity(0.35),
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
                                  const IssueListPage(role: "Volunteer")),
                        );
                      },
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  3,
                  HoverCard(
                    child: FunctionCard(
                      title: "My Group Tasks",
                      icon: Icons.task,
                      color: Colors.white.withOpacity(0.35),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VolunteerGroupPage(place: volunteerPlace),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  4,
                  HoverCard(
                    child: FunctionCard(
                      title: "Donations ($totalDonations)",
                      icon: Icons.volunteer_activism,
                      color: Colors.white.withOpacity(0.35),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const VolunteerDonationPage()),
                      ),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  5,
                  HoverCard(
                    child: FunctionCard(
                      title: "Videos",
                      icon: Icons.video_library,
                      color: Colors.white.withOpacity(0.35),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const VolunteerVideoPage(volunteerName: 'Volunteer',)),
                      ),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  6,
                  HoverCard(
                    child: FunctionCard(
                      title: "Blood Donation",
                      icon: Icons.bloodtype, // use blood drop icon
                      color: Colors.white.withOpacity(0.35),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const VolunteerBloodPage(), // Volunteer page
                        ),
                      ),
                    ),
                  ),
                ),
                _buildAnimatedCard(
  7,
  HoverCard(
    child: FunctionCard(
      title: "Volunteer Report",
      icon: Icons.report, // report icon
      color: Colors.white.withOpacity(0.35),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VolunteerReportPage(
            volunteerName: "Your Volunteer Name", // pass logged-in volunteer name
          ),
        ),
      ),
    ),
  ),
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Role Switcher Popup Menu
  Widget _roleSwitcher(BuildContext context, List<String> roles) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.switch_account, color: Colors.white),
      onSelected: (value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (value == "admin") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const AdminHome()));
          } else if (value == "user") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const UserHome()));
          } else if (value == "volunteer") {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        VolunteerHome(volunteer: widget.volunteer)));
          }
        });
      },
      itemBuilder: (context) => roles
          .map((r) => PopupMenuItem(
                value: r,
                child: Text("${r[0].toUpperCase()}${r.substring(1)} Home"),
              ))
          .toList(),
    );
  }

  /// 🔹 Animated Card
  Widget _buildAnimatedCard(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.1, 1, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  /// 🔹 Functions Dialog
  void _showFunctionsDialog(BuildContext context) {
    int totalDonations = donationsList.fold(0, (sum, d) => sum + d.quantity);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white.withOpacity(0.95),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Quick Access",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Function Items
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildFunctionItem(
                      context,
                      "Required Products",
                      Icons.shopping_cart,
                      Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProductListPage(canAdd: true)),
                        );
                      },
                    ),
                    _buildFunctionItem(
                      context,
                      "Missing Persons",
                      Icons.person_search,
                      Colors.orange,
                      
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MissingPersonListPage(
                                persons: sampleMissingPersons),
                          ),
                        );
                      },
                    ),
                    _buildFunctionItem(
                      context,
                      "Reported Issues",
                      Icons.report_problem,
                      Colors.redAccent,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const IssueListPage(role: "Volunteer")),
                        );
                      },
                    ),
                    _buildFunctionItem(
                      context,
                      "My Group Tasks",
                      Icons.task,
                      Colors.deepPurple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VolunteerGroupPage(
                                place: widget.volunteer?.place ?? "Unknown"),
                          ),
                        );
                      },
                    ),
                    _buildFunctionItem(
                      context,
                      "Donations ($totalDonations)",
                      Icons.volunteer_activism,
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VolunteerDonationPage()),
                        );
                      },
                    ),
                    _buildFunctionItem(
                      context,
                      "Videos",
                      Icons.video_library,
                      Colors.indigo,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VolunteerVideoPage(volunteerName: 'Volunteer',)),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              // Close Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Function Item Builder
  Widget _buildFunctionItem(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }
}
