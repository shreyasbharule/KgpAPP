import 'package:flutter/material.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/features/institution/institution_service.dart';

class InstitutionScreen extends StatefulWidget {
  const InstitutionScreen({super.key, required this.service});

  final InstitutionService service;

  @override
  State<InstitutionScreen> createState() => _InstitutionScreenState();
}

class _InstitutionScreenState extends State<InstitutionScreen> {
  late Future<InstitutionBundle> _bundleFuture;

  @override
  void initState() {
    super.initState();
    _bundleFuture = widget.service.fetchPublicContent();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InstitutionBundle>(
      future: _bundleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load public content: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Departments', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...data.departments.map(
              (department) => Card(
                child: ListTile(
                  title: Text('${department.code} • ${department.name}'),
                  subtitle: Text(department.officeLocation ?? 'Office location not listed'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Notices', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...data.notices.map(
              (notice) => Card(
                child: ListTile(
                  title: Text(notice.title),
                  subtitle: Text(notice.body),
                  trailing: Text(notice.audience),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Events', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...data.events.map(
              (event) => Card(
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                    '${event.department ?? 'General'} • ${event.venue ?? 'TBA'}\n${event.startsAt} - ${event.endsAt}',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
