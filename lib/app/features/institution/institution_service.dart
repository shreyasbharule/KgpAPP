import 'package:login_app_page/app/core/api_client.dart';
import 'package:login_app_page/app/core/cache_store.dart';
import 'package:login_app_page/app/core/models.dart';

class InstitutionService {
  InstitutionService(this._cacheStore, this._apiClient);

  final PublicCacheStore _cacheStore;
  final ApiClient _apiClient;
  bool demoMode = false;

  Future<InstitutionBundle> fetchPublicContent() async {
    if (demoMode) {
      return const InstitutionBundle(
        departments: [
          DepartmentInfo(id: 1, code: "CSE", name: "Computer Science and Engineering", officeLocation: "Block A"),
          DepartmentInfo(id: 2, code: "ECE", name: "Electronics and Communication Engineering", officeLocation: "Block B"),
        ],
        notices: [
          NoticeInfo(id: 1, title: "Demo Notice", body: "Demo mode uses local fixture data.", audience: "student"),
        ],
        events: [
          EventInfo(
            id: 1,
            title: "Demo Hackathon",
            startsAt: DateTime(2026, 1, 10, 9),
            endsAt: DateTime(2026, 1, 10, 18),
            venue: "Innovation Hall",
            department: "CSE",
          ),
        ],
      );
    }

    final cached = _cacheStore.read('public_content', maxAge: const Duration(minutes: 30));
    if (cached != null) {
      return _bundleFromJson(cached);
    }

    final departmentsResponse = await _apiClient.get('/api/v1/public/departments');
    final noticesResponse = await _apiClient.get('/api/v1/public/notices');
    final eventsResponse = await _apiClient.get('/api/v1/public/events');

    List<dynamic> normalize(dynamic value) {
      if (value is List<dynamic>) return value;
      if (value is Map<String, dynamic> && value['items'] is List<dynamic>) {
        return value['items'] as List<dynamic>;
      }
      return const [];
    }

    final payload = {
      'departments': normalize(departmentsResponse.body),
      'notices': normalize(noticesResponse.body),
      'events': normalize(eventsResponse.body),
    };
    await _cacheStore.save('public_content', payload);
    return _bundleFromJson(payload);
  }

  InstitutionBundle _bundleFromJson(Map<String, dynamic> json) {
    final departmentsRaw = (json['departments'] as List<dynamic>? ?? const []);
    final noticesRaw = (json['notices'] as List<dynamic>? ?? const []);
    final eventsRaw = (json['events'] as List<dynamic>? ?? const []);

    return InstitutionBundle(
      departments: departmentsRaw
          .map(
            (item) => DepartmentInfo(
              id: item['id'] as int,
              code: item['code'] as String,
              name: item['name'] as String,
              officeLocation: item['office_location'] as String?,
            ),
          )
          .toList(),
      notices: noticesRaw
          .map(
            (item) => NoticeInfo(
              id: item['id'] as int,
              title: item['title'] as String,
              body: item['body'] as String,
              audience: item['audience'] as String,
              publishedAt: item['published_at'] == null ? null : DateTime.parse(item['published_at'] as String),
            ),
          )
          .toList(),
      events: eventsRaw
          .map(
            (item) => EventInfo(
              id: item['id'] as int,
              title: item['title'] as String,
              description: item['description'] as String?,
              startsAt: DateTime.parse(item['starts_at'] as String),
              endsAt: DateTime.parse(item['ends_at'] as String),
              venue: item['venue'] as String?,
              department: item['department'] as String?,
            ),
          )
          .toList(),
    );
  }
}
