import 'package:login_app_page/app/core/cache_store.dart';

class StudentService {
  StudentService(this._cacheStore);

  final StudentCacheStore _cacheStore;

  Future<List<(String, String)>> fetchStudentActions() async {
    final cached = _cacheStore.read('student_actions');
    if (cached != null) {
      return (cached['items'] as List<dynamic>)
          .map((item) => (item['title'] as String, item['subtitle'] as String))
          .toList();
    }

    const items = [
      ('Profile', 'View personal details and KYC status'),
      ('Timetable', 'Daily and weekly class schedule'),
      ('Attendance', 'Department-wise attendance analytics'),
      ('Grades & Results', 'Semester CGPA and result documents'),
      ('Fee Status', 'Dues, receipts, and transaction history'),
      ('Library', 'Active loans, due dates, and fines'),
    ];

    _cacheStore.save('student_actions', {
      'items': items.map((item) => {'title': item.$1, 'subtitle': item.$2}).toList(),
    });

    return items;
  }
}
