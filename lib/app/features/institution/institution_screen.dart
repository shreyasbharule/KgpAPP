import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InstitutionScreen extends StatelessWidget {
  const InstitutionScreen({super.key});

  static const _links = [
    ('Directory', 'Find departments, offices, and contacts', 'https://university.edu/directory'),
    ('Campus Map', 'Wayfinding and transport routes', 'https://university.edu/map'),
    ('Events', 'Cultural and academic events calendar', 'https://university.edu/events'),
    ('Notices', 'Official circulars and alerts', 'https://university.edu/notices'),
    ('FAQs', 'Student support frequently asked questions', 'https://university.edu/faq'),
    ('Emergency', '24x7 helpline and escalation flow', 'tel:+1800123456'),
  ];

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Unable to launch URI');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _links.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final link = _links[index];
        return Card(
          child: ListTile(
            title: Text(link.$1),
            subtitle: Text(link.$2),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _open(link.$3),
          ),
        );
      },
    );
  }
}
