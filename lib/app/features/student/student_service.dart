import 'package:login_app_page/app/core/api_client.dart';
import 'package:login_app_page/app/core/cache_store.dart';
import 'package:login_app_page/app/core/models.dart';

class StudentService {
  StudentService(this._cacheStore, this._apiClient);

  final StudentCacheStore _cacheStore;
  final ApiClient _apiClient;
  bool demoMode = false;

  Future<StudentAcademicsBundle> fetchAcademics() async {
    if (demoMode) {
      return StudentAcademicsBundle(
        timetable: [
          StudentTimetableEntryInfo(
            id: 1,
            courseCode: "CS201",
            courseName: "Data Structures",
            startsAt: DateTime.now().add(const Duration(hours: 2)),
            endsAt: DateTime.now().add(const Duration(hours: 3)),
            instructorName: "Dr. Demo",
            room: "CSE-201",
          ),
        ],
        grades: const [
          StudentGradeInfo(courseCode: "CS201", courseName: "Data Structures", term: "Autumn-2026", grade: "A", credits: 4),
        ],
      );
    }

    final cached = _cacheStore.read('student_academics');
    if (cached != null) {
      return _bundleFromJson(cached);
    }

    final timetableResponse = await _apiClient.get('/api/v1/student/me/timetable');
    final gradesResponse = await _apiClient.get('/api/v1/student/me/grades');

    final payload = {
      'timetable': (timetableResponse.body as Map<String, dynamic>)['entries'] ?? const [],
      'grades': (gradesResponse.body as Map<String, dynamic>)['grades'] ?? const [],
    };
    _cacheStore.save('student_academics', payload);
    return _bundleFromJson(payload);
  }

  StudentAcademicsBundle _bundleFromJson(Map<String, dynamic> json) {
    final timetableRaw = json['timetable'] as List<dynamic>? ?? const [];
    final gradesRaw = json['grades'] as List<dynamic>? ?? const [];

    return StudentAcademicsBundle(
      timetable: timetableRaw
          .map(
            (item) => StudentTimetableEntryInfo(
              id: item['id'] as int,
              courseCode: item['course_code'] as String,
              courseName: item['course_name'] as String,
              instructorName: item['instructor_name'] as String?,
              room: item['room'] as String?,
              startsAt: DateTime.parse(item['starts_at'] as String),
              endsAt: DateTime.parse(item['ends_at'] as String),
            ),
          )
          .toList(),
      grades: gradesRaw
          .map(
            (item) => StudentGradeInfo(
              courseCode: item['course_code'] as String,
              courseName: item['course_name'] as String?,
              term: item['term'] as String,
              grade: item['grade'] as String,
              credits: (item['credits'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(),
    );
  }
}
