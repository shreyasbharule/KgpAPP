enum UserRole { student, faculty, admin }

class SessionTokens {
  const SessionTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiry;

  bool get isExpired => DateTime.now().isAfter(accessTokenExpiry);

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiry': accessTokenExpiry.toIso8601String(),
    };
  }

  factory SessionTokens.fromJson(Map<String, dynamic> json) {
    return SessionTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiry: DateTime.parse(json['accessTokenExpiry'] as String),
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
}

class UserSession {
  const UserSession({required this.user, required this.tokens});

  final AppUser user;
  final SessionTokens tokens;
}

class DashboardCardData {
  final String title;
  final String subtitle;

  const DashboardCardData({required this.title, required this.subtitle});
}

class DepartmentInfo {
  const DepartmentInfo({
    required this.id,
    required this.code,
    required this.name,
    this.officeLocation,
  });

  final int id;
  final String code;
  final String name;
  final String? officeLocation;
}

class NoticeInfo {
  const NoticeInfo({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    this.publishedAt,
  });

  final int id;
  final String title;
  final String body;
  final String audience;
  final DateTime? publishedAt;
}

class EventInfo {
  const EventInfo({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    this.description,
    this.venue,
    this.department,
  });

  final int id;
  final String title;
  final String? description;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? venue;
  final String? department;
}

class InstitutionBundle {
  const InstitutionBundle({
    required this.departments,
    required this.notices,
    required this.events,
  });

  final List<DepartmentInfo> departments;
  final List<NoticeInfo> notices;
  final List<EventInfo> events;
}

class StudentGradeInfo {
  const StudentGradeInfo({
    required this.courseCode,
    required this.term,
    required this.grade,
    required this.credits,
    this.courseName,
  });

  final String courseCode;
  final String? courseName;
  final String term;
  final String grade;
  final int credits;
}

class StudentTimetableEntryInfo {
  const StudentTimetableEntryInfo({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.startsAt,
    required this.endsAt,
    this.instructorName,
    this.room,
  });

  final int id;
  final String courseCode;
  final String courseName;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? instructorName;
  final String? room;
}

class StudentAcademicsBundle {
  const StudentAcademicsBundle({required this.timetable, required this.grades});

  final List<StudentTimetableEntryInfo> timetable;
  final List<StudentGradeInfo> grades;
}
