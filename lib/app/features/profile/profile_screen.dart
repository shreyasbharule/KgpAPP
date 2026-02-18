import 'package:flutter/material.dart';
import 'package:login_app_page/app/core/config.dart';
import 'package:login_app_page/app/core/models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user, required this.onLogout});

  final AppUser user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.name),
              subtitle: Text('${user.email}\nEnvironment: ${AppConfig.envName}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
