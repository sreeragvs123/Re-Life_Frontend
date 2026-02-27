// lib/pages/admin_home.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'admin_report_page.dart';
import 'admin_issue_page.dart';
import 'admin_video_approval_page.dart';
import 'shelter_list_page.dart';
import 'product_list_page.dart';
import 'admin_missing_person_page.dart';
import 'admin_donation_page.dart';
import 'admin_volunteer_list_page.dart';
import 'evacuation_map_page.dart';
import 'user_home.dart';
import 'volunteer_home.dart';
import 'video_gallery_page.dart';
import 'login_page.dart';
import '../models/volunteer.dart';
import '../widgets/function_card.dart';
import '../api/auth_api.dart';
import '../api/donation_api.dart';
import '../api/issue_api.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int  _totalDonations    = 0;
  int  _pendingIssueCount = 0;
  bool _hasNewIssue       = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))..forward();
    _loadCounts();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _loadCounts() async =>
      Future.wait([_loadDonationCount(), _loadIssueCount()]);

  Future<void> _loadDonationCount() async {
    try {
      final d = await DonationApi.getApprovedDonations();
      if (mounted) setState(() =>
          _totalDonations = d.fold(0, (s, x) => s + x.quantity));
    } catch (_) {}
  }

  Future<void> _loadIssueCount() async {
    try {
      final i = await IssueApi.getAllIssues();
      if (mounted) setState(() {
        _pendingIssueCount = i.length;
        _hasNewIssue       = i.isNotEmpty;
      });
    } catch (_) {}
  }

  // ── Sign out → LoginPage ──────────────────────────────────────────────────
  void _signOut() async {
    await AuthApi.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _openReportedIssues() async {
    setState(() => _hasNewIssue = false);
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AdminIssuePage()));
    _loadIssueCount();
  }

  void _openVolunteerReports() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const AdminReportPage()));

  void _openDonations() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AdminDonationPage()));
    _loadDonationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        shadowColor: Colors.deepPurpleAccent,
        elevation: 8,
        title: Text('Admin Dashboard',
            style: GoogleFonts.bebasNeue(
                fontSize: 28, letterSpacing: 1.2, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadCounts),
          IconButton(icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _showFunctionsDialog(context)),
          TextButton(onPressed: _signOut,
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.white))),
          // ADMIN can switch to all 3 homes
          PopupMenuButton<String>(
            icon: const Icon(Icons.switch_account, color: Colors.white),
            onSelected: _handleRoleSwitch,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'admin',     child: Text('Admin Home')),
              PopupMenuItem(value: 'volunteer', child: Text('Volunteer Home')),
              PopupMenuItem(value: 'user',      child: Text('User Home')),
            ],
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
                _card(0, _hover(FunctionCard(title: 'Evacuation Map', icon: Icons.map,
                  color: Colors.white.withOpacity(0.4), textSize: 18, fontWeight: FontWeight.bold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const EvacuationMapPage(isAdmin: true)))))),
                _card(1, _hover(FunctionCard(title: 'Manage Shelters', icon: Icons.home_work,
                  color: Colors.white.withOpacity(0.4), textSize: 18, fontWeight: FontWeight.bold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ShelterListPage(isAdmin: true)))))),
                _card(2, _hover(FunctionCard(title: 'Volunteers & Tasks', icon: Icons.group,
                  color: Colors.white.withOpacity(0.4), textSize: 18, fontWeight: FontWeight.bold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AdminVolunteerListPage()))))),
                _card(3, _hover(FunctionCard(title: 'Required Products', icon: Icons.shopping_cart,
                  color: Colors.white.withOpacity(0.4), textSize: 18, fontWeight: FontWeight.bold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ProductListPage(canAdd: true)))))),
                _card(4, _hover(FunctionCard(title: 'Missing Persons', icon: Icons.person,
                  color: Colors.white.withOpacity(0.4), textSize: 18, fontWeight: FontWeight.bold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AdminMissingPersonPage()))))),
                _card(5, _hover(FunctionCard(
                  title: 'Reported Issues ($_pendingIssueCount)',
                  icon: Icons.report_problem,
                  color: Colors.white.withOpacity(0.4), textSize: 18, fontWeight: FontWeight.bold,
                  badge: _hasNewIssue ? Container(width: 14, height: 14,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle)) : null,
                  onTap: _openReportedIssues,
                ))),
                _card(6, _hover(FunctionCard(title: 'Videos', icon: Icons.video_library,
                  color: Colors.white.withOpacity(0.4), textSize: 18, fontWeight: FontWeight.bold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AdminVideoApprovalPage()))))),
                _card(7, _hover(FunctionCard(
                  title: 'Donations ($_totalDonations)',
                  icon: Icons.volunteer_activism,
                  color: Colors.white.withOpacity(0.35), textSize: 18, fontWeight: FontWeight.bold,
                  onTap: _openDonations,
                ))),
                _card(8, _hover(FunctionCard(title: 'Volunteer Reports', icon: Icons.report,
                  color: Colors.white.withOpacity(0.35), textSize: 18, fontWeight: FontWeight.bold,
                  onTap: _openVolunteerReports))),
              ],
            ),
          ),
        ],
      ),
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

  Widget _hover(Widget child) {
    return StatefulBuilder(builder: (ctx, set) {
      bool h = false;
      return MouseRegion(
        onEnter: (_) => set(() => h = true),
        onExit:  (_) => set(() => h = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: h
              ? (Matrix4.identity()..translate(0, -8, 0)..scale(1.03))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: h
                ? [BoxShadow(color: Colors.black.withOpacity(0.3),
                    blurRadius: 20, offset: const Offset(0, 8))]
                : [],
          ),
          child: child,
        ),
      );
    });
  }

  Widget _card(int index, Widget child) {
    final anim = CurvedAnimation(parent: _controller,
        curve: Interval(index * 0.1, 1, curve: Curves.easeOutBack));
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(0, 0.2), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }

  void _showFunctionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        title: const Text('Quick Access'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(shrinkWrap: true, children: [
            _dlgItem(context, 'Evacuation Map', Icons.map, () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EvacuationMapPage(isAdmin: true)))),
            _dlgItem(context, 'Manage Shelters', Icons.home_work, () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ShelterListPage(isAdmin: true)))),
            _dlgItem(context, 'Volunteers & Tasks', Icons.group, () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminVolunteerListPage()))),
            _dlgItem(context, 'Required Products', Icons.shopping_cart, () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListPage(canAdd: true)))),
            _dlgItem(context, 'Missing Persons', Icons.person, () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMissingPersonPage()))),
            _dlgItem(context, 'Reported Issues ($_pendingIssueCount)', Icons.report_problem, () {
              Navigator.pop(context); _openReportedIssues();
            }),
            _dlgItem(context, 'Donations ($_totalDonations)', Icons.volunteer_activism, () {
              Navigator.pop(context); _openDonations();
            }),
            _dlgItem(context, 'Videos', Icons.video_library, () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoGalleryPage()))),
            _dlgItem(context, 'Volunteer Reports', Icons.report, () {
              Navigator.pop(context); _openVolunteerReports();
            }),
          ]),
        ),
        actions: [TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'))],
      ),
    );
  }

  Widget _dlgItem(BuildContext ctx, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () { Navigator.pop(ctx); onTap(); },
    );
  }

  void _handleRoleSwitch(String value) {
    if (value == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already on Admin Home')));
      return;
    }
    if (value == 'user') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const UserHome()));
      return;
    }
    if (value == 'volunteer') {
      final box   = Hive.box('authBox');
      final email = box.get('email') as String? ?? '';
      final name  = box.get('name')  as String? ?? 'Admin';
      final place = box.get('place') as String? ?? 'Admin Center';
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => VolunteerHome(
            volunteer: Volunteer(
                name: name, place: place, email: email, password: ''),
          )));
    }
  }
}