import 'package:flutter/material.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/features/admin/admin_screen.dart';
import 'package:login_app_page/app/features/dashboard/dashboard_screen.dart';
import 'package:login_app_page/app/features/institution/institution_screen.dart';
import 'package:login_app_page/app/features/profile/profile_screen.dart';
import 'package:login_app_page/app/features/student/student_services_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.institutionScreen,
    required this.studentScreen,
    required this.onLogout,
  });

  final AppUser user;
  final InstitutionScreen institutionScreen;
  final StudentServicesScreen studentScreen;
  final Future<void> Function() onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(user: widget.user),
      widget.institutionScreen,
      widget.studentScreen,
      if (widget.user.role == UserRole.admin) const AdminScreen(),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout),
    ];

    final destinations = [
      const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      const NavigationDestination(icon: Icon(Icons.school), label: 'Institution'),
      const NavigationDestination(icon: Icon(Icons.badge), label: 'Student'),
      if (widget.user.role == UserRole.admin)
        const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
      const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
    ];

    if (_index >= screens.length) {
      _index = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('University Student App (${widget.user.role.name})'),
      ),
      body: screens[_index],
      floatingActionButton: widget.user.role == UserRole.admin
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin-only quick action.')),
                );
              },
              icon: const Icon(Icons.add_task),
              label: const Text('Admin Action'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations,
      ),
    );
  }
}
