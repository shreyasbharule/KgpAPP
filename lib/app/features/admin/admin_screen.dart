import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('User Provisioning'),
            subtitle: Text('Create and manage university staff accounts'),
          ),
        ),
        SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: Icon(Icons.report_gmailerrorred),
            title: Text('Compliance Queue'),
            subtitle: Text('Review pending compliance escalations'),
          ),
        ),
      ],
    );
  }
}
