// lib/pages/volunteer_home.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'volunteer_blood_page.dart';
import 'volunteer_donation_page.dart';
import 'volunteer_report_page.dart';
import 'volunteer_video_page.dart';
import 'volunteer_issue_page.dart';
import '../widgets/function_card.dart';
import 'product_list_page.dart';
import 'missing_person_list_page.dart';
import 'volunteer_group_page.dart';
import 'evacuation_map_page.dart';
import '../models/volunteer.dart';
import '../pages/user_home.dart';
import '../pages/admin_home.dart';
import '../pages/login_page.dart';
import '../api/auth_api.dart';
import '../api/donation_api.dart';
import '../api/issue_api.dart';

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
      onExit:  (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: hovering
            ? (Matrix4.identity()..translate(0, -8, 0)..scale(1.03))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: hovering
              ? [BoxShadow(color: Colors.black.withOpacity(0.3),
                  blurRadius: 20, offset: const Offset(0, 8))]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

class VolunteerHome extends StatefulWidget {
  final Volunteer? volunteer;
  const VolunteerHome({super.key, this.volunteer});
  @override
  State<VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int  _totalDonations = 0;
  int  _issueCount     = 0;
  bool _hasNewIssue    = false;

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
        _issueCount  = i.length;
        _hasNewIssue = i.isNotEmpty;
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
        MaterialPageRoute(builder: (_) => const VolunteerIssuePage()));
    _loadIssueCount();
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
    final volunteerName  = widget.volunteer?.name  ?? 'Guest Volunteer';
    final volunteerPlace = widget.volunteer?.place ?? 'Unknown Place';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        shadowColor: Colors.deepPurpleAccent,
        elevation: 8,
        title: Text('Volunteer Dashboard ($volunteerName)',
            style: GoogleFonts.bebasNeue(
                fontSize: 28, letterSpacing: 1.2, color: Colors.white)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadCounts),
          // Role switcher — VOLUNTEER sees User + Volunteer only
          // ADMIN sees all 3 (if admin uses this home via role switch)
          Builder(builder: (ctx) {
            final role = Hive.box('authBox').get('role') as String?;
            if (role == 'ADMIN') {
              return _roleSwitcher(ctx, ['admin', 'user', 'volunteer']);
            } else if (role == 'VOLUNTEER') {
              return _roleSwitcher(ctx, ['user', 'volunteer']);
            }
            return const SizedBox();
          }),
          TextButton(
              onPressed: _signOut,
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.white))),
          IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () =>
                  _showFunctionsDialog(context, volunteerName, volunteerPlace)),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildAnimatedBackground()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                _card(0, HoverCard(child: FunctionCard(
                  title: 'Required Products', icon: Icons.shopping_cart,
                  color: Colors.white.withOpacity(0.35),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProductListPage(canAdd: true))),
                ))),
                _card(1, HoverCard(child: FunctionCard(
                  title: 'Missing Persons', icon: Icons.person_search,
                  color: Colors.white.withOpacity(0.35),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MissingPersonListPage())),
                ))),
                _card(2, HoverCard(child: FunctionCard(
                  title: 'Reported Issues ($_issueCount)',
                  icon: Icons.report_problem,
                  color: Colors.white.withOpacity(0.35),
                  badge: _hasNewIssue
                      ? Container(width: 14, height: 14,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle))
                      : null,
                  onTap: _openReportedIssues,
                ))),
                _card(3, HoverCard(child: FunctionCard(
                  title: 'My Group Tasks', icon: Icons.task,
                  color: Colors.white.withOpacity(0.35),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                          VolunteerGroupPage(place: volunteerPlace))),
                ))),
                _card(4, HoverCard(child: FunctionCard(
                  title: 'Donations ($_totalDonations)',
                  icon: Icons.volunteer_activism,
                  color: Colors.white.withOpacity(0.35),
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VolunteerDonationPage()));
                    _loadDonationCount();
                  },
                ))),
                _card(5, HoverCard(child: FunctionCard(
                  title: 'Videos', icon: Icons.video_library,
                  color: Colors.white.withOpacity(0.35),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                          VolunteerVideoPage(volunteerName: volunteerName))),
                ))),
                _card(6, HoverCard(child: FunctionCard(
                  title: 'Blood Donation', icon: Icons.bloodtype,
                  color: Colors.white.withOpacity(0.35),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VolunteerBloodPage())),
                ))),
                _card(7, HoverCard(child: FunctionCard(
                  title: 'My Work Report', icon: Icons.report,
                  color: Colors.white.withOpacity(0.35),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                          VolunteerReportPage(volunteerName: volunteerName))),
                ))),
                _card(8, HoverCard(child: FunctionCard(
                  title: 'Evacuation Map', icon: Icons.map,
                  color: Colors.white.withOpacity(0.35),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                          const EvacuationMapPage(isAdmin: false))),
                ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Role switcher — only shows roles the current user is allowed ──────────
  Widget _roleSwitcher(BuildContext context, List<String> roles) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.switch_account, color: Colors.white),
      onSelected: (value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (value == 'admin') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AdminHome()));
          } else if (value == 'user') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const UserHome()));
          } else if (value == 'volunteer') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) =>
                    VolunteerHome(volunteer: widget.volunteer)));
          }
        });
      },
      itemBuilder: (_) => roles.map((r) => PopupMenuItem(
        value: r,
        child: Text('${r[0].toUpperCase()}${r.substring(1)} Home'),
      )).toList(),
    );
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

  void _showFunctionsDialog(BuildContext ctx, String name, String place) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withOpacity(0.95),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 520),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Quick Access',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 16),
            Expanded(child: ListView(shrinkWrap: true, children: [
              _dialogItem(ctx, 'Required Products', Icons.shopping_cart, Colors.teal, () =>
                  Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProductListPage(canAdd: true)))),
              _dialogItem(ctx, 'Missing Persons', Icons.person_search, Colors.orange, () =>
                  Navigator.push(ctx, MaterialPageRoute(builder: (_) => const MissingPersonListPage()))),
              _dialogItem(ctx, 'Reported Issues ($_issueCount)', Icons.report_problem, Colors.redAccent, () {
                Navigator.pop(ctx); _openReportedIssues();
              }),
              _dialogItem(ctx, 'My Group Tasks', Icons.task, Colors.deepPurple, () =>
                  Navigator.push(ctx, MaterialPageRoute(builder: (_) => VolunteerGroupPage(place: place)))),
              _dialogItem(ctx, 'Donations ($_totalDonations)', Icons.volunteer_activism, Colors.green, () =>
                  Navigator.push(ctx, MaterialPageRoute(builder: (_) => const VolunteerDonationPage()))),
              _dialogItem(ctx, 'Videos', Icons.video_library, Colors.indigo, () =>
                  Navigator.push(ctx, MaterialPageRoute(builder: (_) => VolunteerVideoPage(volunteerName: name)))),
              _dialogItem(ctx, 'My Work Report', Icons.report, Colors.purple, () =>
                  Navigator.push(ctx, MaterialPageRoute(builder: (_) => VolunteerReportPage(volunteerName: name)))),
              _dialogItem(ctx, 'Evacuation Map', Icons.map, Colors.teal, () =>
                  Navigator.push(ctx, MaterialPageRoute(builder: (_) => const EvacuationMapPage(isAdmin: false)))),
            ])),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _dialogItem(BuildContext ctx, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color,
            child: Icon(icon, color: Colors.white)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () { Navigator.pop(ctx); onTap(); },
      ),
    );
  }
}