import 'package:flutter/material.dart';

class StudentServicesScreen extends StatelessWidget {
  const StudentServicesScreen({super.key});

  static const _items = [
    ('Profile', 'View personal details and KYC status'),
    ('Timetable', 'Daily and weekly class schedule'),
    ('Attendance', 'Department-wise attendance analytics'),
    ('Grades & Results', 'Semester CGPA and result documents'),
    ('Fee Status', 'Dues, receipts, and transaction history'),
    ('Library', 'Active loans, due dates, and fines'),
    ('Certificates', 'Apply for bonafide/transcript requests'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _items.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.$2),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feature wired for backend integration.')),
            );
          },
        );
      },
    );
  }
}
