import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'user_blood_page.dart';
import 'package:Relife/pages/user_donation_page.dart';

import '../widgets/function_card.dart';
import 'shelter_list_page.dart';
import 'product_list_page.dart';
import 'missing_person_list_page.dart';
import '../api/donation_api.dart';
import 'video_gallery_page.dart';
import 'report_issue_page.dart';
import 'volunteer_registration_page.dart';
import 'login_page.dart';
import 'admin_home.dart';
import 'volunteer_home.dart';
import '../models/volunteer.dart';
import 'donation_page.dart';
import 'evacuation_map_page.dart';           // ⭐ NEW

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome>
    with SingleTickerProviderStateMixin {
  bool hasNewIssue = false;
  late AnimationController _controller;
  String? role;
  int totalDonations = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..forward();
    _loadRole();
    _loadDonationCount();
  }

  void _loadRole() {
    var box = Hive.box('authBox');
    setState(() => role = box.get('role'));
  }

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

  void _signOut() {
    var box = Hive.box('authBox');
    box.put('isLoggedIn', false);
    box.put('role', null);
    box.delete('email');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UserHome()),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 1,
        shadowColor: Colors.deepPurpleAccent,
        title: Text(
          "RELIFE",
          style: GoogleFonts.bebasNeue(
              fontSize: 28, letterSpacing: 1.2, color: Colors.white),
        ),
        actions: [
          if (role == "ADMIN" || role == "VOLUNTEER")
            PopupMenuButton<String>(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              icon: const Icon(Icons.switch_account, color: Colors.white),
              onSelected: (value) {
                if (value == "admin") {
                  Navigator.pushReplacement(
                      context, _createRoute(const AdminHome()));
                } else if (value == "user") {
                  Navigator.pushReplacement(
                      context, _createRoute(const UserHome()));
                } else if (value == "volunteer") {
                  Volunteer volunteerToOpen;
                  if (role == "VOLUNTEER") {
                    var volunteersBox = Hive.box('volunteersBox');
                    String? email = Hive.box('authBox').get('email');
                    if (email != null && volunteersBox.containsKey(email)) {
                      var data = volunteersBox.get(email);
                      volunteerToOpen = Volunteer(
                          name: data['name'],
                          place: data['place'],
                          email: email,
                          password: data['password']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Volunteer data not found!")));
                      return;
                    }
                  } else {
                    volunteerToOpen = Volunteer(
                        name: "Admin Volunteer",
                        place: "Admin Center",
                        email: "admin@admin.com",
                        password: "admin123");
                  }
                  Navigator.pushReplacement(
                      context,
                      _createRoute(
                          VolunteerHome(volunteer: volunteerToOpen)));
                }
              },
              itemBuilder: (context) {
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
            ),
          if (role != null && role != "USER")
            TextButton(
              onPressed: _signOut,
              child: const Text("Sign Out",
                  style: TextStyle(color: Colors.white)),
            )
          else
            TextButton(
              onPressed: () =>
                  Navigator.push(context, _createRoute(const LoginPage())),
              child: const Text("Login",
                  style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showFunctionsDialog(context),
          ),
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
                _buildAnimatedCard(
                  0,
                  FunctionCard(
                    title: "Shelters",
                    icon: Icons.home,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                        context, _createRoute(const ShelterListPage())),
                  ),
                ),
                _buildAnimatedCard(
                  1,
                  FunctionCard(
                    title: "Required Products",
                    icon: Icons.shopping_cart,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                        context,
                        _createRoute(ProductListPage(canAdd: false))),
                  ),
                ),
                _buildAnimatedCard(
                  2,
                  FunctionCard(
                    title: "Payment",
                    icon: Icons.payment,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                        context, _createRoute(const DonationPage())),
                  ),
                ),
                _buildAnimatedCard(
                  3,
                  FunctionCard(
                    title: "Missing Persons",
                    icon: Icons.person_search,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                        context,
                        _createRoute(const MissingPersonListPage())),
                  ),
                ),
                _buildAnimatedCard(
                  4,
                  FunctionCard(
                    title: "Report an Issue",
                    icon: Icons.report_problem,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    badge: hasNewIssue
                        ? Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.redAccent,
                                    blurRadius: 8,
                                    spreadRadius: 2)
                              ],
                            ),
                          )
                        : null,
                    onTap: () async {
                      final submitted = await Navigator.push(
                          context, _createRoute(const ReportIssuePage()));
                      if (submitted == true) {
                        setState(() => hasNewIssue = true);
                      }
                    },
                  ),
                ),
                _buildAnimatedCard(
                  5,
                  FunctionCard(
                    title: "Volunteer Registration",
                    icon: Icons.group_add,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                        context,
                        _createRoute(const VolunteerRegistrationPage())),
                  ),
                ),
                _buildAnimatedCard(
                  6,
                  FunctionCard(
                    title: "Videos",
                    icon: Icons.video_library,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                        context, _createRoute(const VideoGalleryPage())),
                  ),
                ),
                _buildAnimatedCard(
                  7,
                  FunctionCard(
                    title: "Blood Donation",
                    icon: Icons.bloodtype,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                        context, _createRoute(const UserBloodPage())),
                  ),
                ),
                _buildAnimatedCard(
                  8,
                  FunctionCard(
                    title: "Donations ($totalDonations)",
                    icon: Icons.volunteer_activism,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () async {
                      var box = Hive.box('authBox');
                      String userName = box.get('name') ?? "Guest";
                      String userContact = box.get('contact') ?? "N/A";
                      String userAddress = box.get('address') ?? "N/A";
                      await Navigator.push(
                          context,
                          _createRoute(UserDonationPage(
                            userName: userName,
                            userContact: userContact,
                            userAddress: userAddress,
                          )));
                      await _loadDonationCount();
                    },
                  ),
                ),

                // ⭐ NEW: Evacuation Map card for users
                _buildAnimatedCard(
                  9,
                  FunctionCard(
                    title: "Evacuation Map",
                    icon: Icons.map,
                    color: Colors.white,
                    textSize: 18,
                    fontWeight: FontWeight.bold,
                    onTap: () => Navigator.push(
                      context,
                      _createRoute(
                          const EvacuationMapPage(isAdmin: false)),
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

  Widget _buildAnimatedCard(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.1, 1, curve: Curves.easeOutBack),
    );
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(2, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
              parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  void _showFunctionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
            parent: _controller, curve: Curves.elasticOut),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text("Quick Access"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildFunctionItem(context, "Shelters", Icons.home, () {
                  Navigator.push(
                      context, _createRoute(const ShelterListPage()));
                }),
                _buildFunctionItem(
                    context, "Required Products", Icons.shopping_cart, () {
                  Navigator.push(
                      context,
                      _createRoute(ProductListPage(canAdd: false)));
                }),
                _buildFunctionItem(
                    context, "Missing Persons", Icons.person_search, () {
                  Navigator.push(
                      context,
                      _createRoute(const MissingPersonListPage()));
                }),
                _buildFunctionItem(
                    context, "Report an Issue", Icons.report_problem, () {
                  Navigator.push(
                      context, _createRoute(const ReportIssuePage()));
                }),
                _buildFunctionItem(
                    context, "Volunteer Registration", Icons.group_add, () {
                  Navigator.push(
                      context,
                      _createRoute(const VolunteerRegistrationPage()));
                }),
                _buildFunctionItem(
                    context, "Videos", Icons.video_library, () {
                  Navigator.push(
                      context, _createRoute(const VideoGalleryPage()));
                }),
                // ⭐ NEW in quick access
                _buildFunctionItem(
                    context, "Evacuation Map", Icons.map, () {
                  Navigator.push(
                      context,
                      _createRoute(
                          const EvacuationMapPage(isAdmin: false)));
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
      ),
    );
  }

  Widget _buildFunctionItem(BuildContext context, String title,
      IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}