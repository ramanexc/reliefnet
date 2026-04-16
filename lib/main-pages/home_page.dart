import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reliefnet/main-pages/dashboard_page.dart';
import 'package:reliefnet/secondary-pages/profile_page.dart';
import 'package:reliefnet/main-pages/report_page.dart';
import 'package:reliefnet/secondary-pages/settings_page.dart';
import 'package:reliefnet/main-pages/volunteer_page.dart';
import 'package:reliefnet/main-pages/apply_volunteer_page.dart';
import 'package:reliefnet/components/app_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedindex = 0;
  bool _isVolunteer = false;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(
        isVolunteer: _isVolunteer,
        onNavigateToReport: () => setState(() => selectedindex = 1),
        onNavigateToApply: () => setState(() => selectedindex = 4),
      ),
      const ReportPage(),
      const DashboardPage(),
      const VolunteerPage(),
      const ApplyVolunteerPage(),
      const ProfilePage(),
      const SettingsPage(),
    ];
    _checkVolunteerStatus();
  }

  Future<void> _checkVolunteerStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && mounted) {
          setState(() {
            _isVolunteer = doc.data()?['isVolunteer'] ?? false;
            // Update the HomeContent within the list when status changes
            _pages[0] = HomeContent(
              isVolunteer: _isVolunteer,
              onNavigateToReport: () => setState(() => selectedindex = 1),
              onNavigateToApply: () => setState(() => selectedindex = 4),
            );
          });
        }
      });
    }
  }

  final List<String> _pageTitles = [
    'Relief Net',
    'Report Issue',
    'Dashboard',
    'Volunteer',
    'Application status',
    'Profile',
    'Settings',
  ];

  void _navigate(int index) {
    setState(() => selectedindex = index);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBarComponent(appBarText: _pageTitles[selectedindex]),

      body: _pages[selectedindex],

      drawer: Drawer(
        width: 240,
        child: Column(
          children: [
            /// 🔹 Header
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.png", height: 80),
                  const SizedBox(height: 10),
                  Text("ReliefNet", style: textTheme.bodyLarge),
                ],
              ),
            ),

            /// 🔹 Main Items
            _buildTile(Icons.home_outlined, "Home", 0, textTheme),
            _buildTile(Icons.report_outlined, "Report", 1, textTheme),

            if (_isVolunteer) ...[
              _buildTile(Icons.dashboard_outlined, "Dashboard", 2, textTheme),
              _buildTile(Icons.help_outline, "Volunteer", 3, textTheme),
            ] else
              ListTile(
                leading: const Icon(Icons.volunteer_activism_outlined),
                title: Text("Apply as Volunteer", style: textTheme.bodyMedium),
                selected: selectedindex == 4, // Highlight when index is 4
                onTap: () => _navigate(4), // Navigate to index 4
              ),

            /// 🔹 Secondary Items (Updated Indices)
            _buildTile(Icons.person_outline, "Profile", 5, textTheme),
            _buildTile(Icons.settings_outlined, "Settings", 6, textTheme),
            const Spacer(),

            /// 🔹 Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                "Logout",
                style: textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
              onTap: () => _showLogoutDialog(context, textTheme),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔥 Reusable Tile (cleaner code)
  Widget _buildTile(
    IconData icon,
    String title,
    int index,
    TextTheme textTheme,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: textTheme.bodyMedium),
      selected: selectedindex == index,
      onTap: () => _navigate(index),
    );
  }

  /// 🔥 Logout Dialog (clean + themed)
  void _showLogoutDialog(BuildContext context, TextTheme textTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: textTheme.bodyLarge),
        content: Text(
          "Are you sure you want to logout?",
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: textTheme.bodySmall),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
            child: Text(
              "Logout",
              style: textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final bool isVolunteer;
  final VoidCallback onNavigateToReport;
  final VoidCallback onNavigateToApply;

  const HomeContent({
    super.key,
    required this.isVolunteer,
    required this.onNavigateToReport,
    required this.onNavigateToApply,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Report an Issue Button
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: onNavigateToReport,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Report an Issue",
                            style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Need help? Let us know immediately.",
                            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2) Becoming a Volunteer Banner (only if not a volunteer)
          if (!isVolunteer)
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.volunteer_activism, color: Colors.blue.shade700, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Make a Difference", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text("Join our team of volunteers today!", style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onNavigateToApply,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                      child: const Text("Apply"),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // 3) Active Reports (for current user)
          Text("My Active Reports", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reports')
                .where('reporterId', isEqualTo: user?.uid)
                .where('status', isNotEqualTo: 'completed')
                .orderBy('status')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No active reports found.");

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: _getIconForType(doc['issueType']),
                      title: Text(doc['issueType'] ?? 'Unknown Issue'),
                      subtitle: Text("Status: ${doc['status']}"),
                      trailing: _getStatusChip(doc['status']),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // 4) Pending Tasks (for volunteer)
          if (isVolunteer) ...[
            Text("Pending Tasks", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('assignedTo', isEqualTo: user?.uid)
                  .where('status', whereIn: ['assigned', 'in_progress', 'reached'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No pending tasks.");

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return Card(
                      color: Colors.green.shade50,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.assignment, color: Colors.green),
                        title: Text(doc['issueType'] ?? 'Task'),
                        subtitle: Text("Urgency: ${doc['urgency']}"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to details or volunteer page
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _getIconForType(String? type) {
    switch (type) {
      case 'Food': return const Icon(Icons.fastfood, color: Colors.orange);
      case 'Medical': return const Icon(Icons.medical_services, color: Colors.red);
      case 'Shelter': return const Icon(Icons.home, color: Colors.blue);
      default: return const Icon(Icons.help_center, color: Colors.grey);
    }
  }

  Widget _getStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'assigned') color = Colors.blue;
    if (status == 'in_progress') color = Colors.orange;
    if (status == 'reached') color = Colors.purple;

    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
