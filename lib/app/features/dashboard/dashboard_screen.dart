import 'package:flutter/material.dart';
import 'package:login_app_page/app/core/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardCardData(title: 'Welcome', subtitle: user.name),
      const DashboardCardData(title: 'Role', subtitle: 'Access: role-aware controls enabled'),
      const DashboardCardData(title: 'Session', subtitle: 'Auto-refresh and expiry handling active'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Card(
        child: ListTile(
          title: Text(cards[index].title),
          subtitle: Text(cards[index].subtitle),
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: cards.length,
    );
  }
}
