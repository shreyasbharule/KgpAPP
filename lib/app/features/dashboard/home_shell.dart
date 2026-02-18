import 'package:flutter/material.dart';
import 'package:login_app_page/app/features/institution/institution_screen.dart';
import 'package:login_app_page/app/features/student/student_services_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [InstitutionScreen(), StudentServicesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('University Student App')),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.school), label: 'Institution'),
          NavigationDestination(icon: Icon(Icons.badge), label: 'Student'),
        ],
      ),
    );
  }
}
