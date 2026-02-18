import 'package:flutter/material.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/features/institution/institution_service.dart';
import 'package:url_launcher/url_launcher.dart';

class InstitutionScreen extends StatefulWidget {
  const InstitutionScreen({super.key, required this.service});

  final InstitutionService service;

  @override
  State<InstitutionScreen> createState() => _InstitutionScreenState();
}

class _InstitutionScreenState extends State<InstitutionScreen> {
  late Future<List<InstitutionLink>> _linksFuture;

  @override
  void initState() {
    super.initState();
    _linksFuture = widget.service.fetchPublicLinks();
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Unable to launch URI');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InstitutionLink>>(
      future: _linksFuture,
      builder: (context, snapshot) {
        final links = snapshot.data ?? const <InstitutionLink>[];
        return ListView.builder(
          itemCount: links.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final link = links[index];
            return Card(
              child: ListTile(
                title: Text(link.title),
                subtitle: Text(link.details),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _open(link.url),
              ),
            );
          },
        );
      },
    );
  }
}
