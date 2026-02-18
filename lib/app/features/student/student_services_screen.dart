import 'package:flutter/material.dart';
import 'package:login_app_page/app/features/student/student_service.dart';

class StudentServicesScreen extends StatefulWidget {
  const StudentServicesScreen({super.key, required this.service});

  final StudentService service;

  @override
  State<StudentServicesScreen> createState() => _StudentServicesScreenState();
}

class _StudentServicesScreenState extends State<StudentServicesScreen> {
  late Future<List<(String, String)>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = widget.service.fetchStudentActions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<(String, String)>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <(String, String)>[];
        return ListView.separated(
          itemCount: items.length,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.$1} is scaffolded for backend integration.')),
                );
              },
            );
          },
        );
      },
    );
  }
}
