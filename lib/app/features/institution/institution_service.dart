import 'package:login_app_page/app/core/cache_store.dart';
import 'package:login_app_page/app/core/models.dart';

class InstitutionService {
  InstitutionService(this._cacheStore);

  final PublicCacheStore _cacheStore;

  Future<List<InstitutionLink>> fetchPublicLinks() async {
    final cached = _cacheStore.read('public_links', maxAge: const Duration(hours: 24));
    if (cached != null) {
      final list = cached['items'] as List<dynamic>;
      return list
          .map((item) => InstitutionLink(
                title: item['title'] as String,
                details: item['details'] as String,
                url: item['url'] as String,
              ))
          .toList();
    }

    final links = _defaultLinks;
    await _cacheStore.save('public_links', {
      'items': links
          .map((item) => {'title': item.title, 'details': item.details, 'url': item.url})
          .toList(),
    });
    return links;
  }

  static const _defaultLinks = <InstitutionLink>[
    InstitutionLink(
      title: 'Directory',
      details: 'Find departments, offices, and contacts',
      url: 'https://university.edu/directory',
    ),
    InstitutionLink(
      title: 'Campus Map',
      details: 'Wayfinding and transport routes',
      url: 'https://university.edu/map',
    ),
    InstitutionLink(
      title: 'Events',
      details: 'Cultural and academic events calendar',
      url: 'https://university.edu/events',
    ),
    InstitutionLink(
      title: 'Notices',
      details: 'Official circulars and alerts',
      url: 'https://university.edu/notices',
    ),
  ];
}
