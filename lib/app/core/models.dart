enum UserRole { student, admin }

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

class InstitutionLink {
  final String title;
  final String details;
  final String url;

  const InstitutionLink({
    required this.title,
    required this.details,
    required this.url,
  });
}

class StudentProfile {
  final String name;
  final String rollNo;
  final String department;
  final double attendance;
  final String feeStatus;

  const StudentProfile({
    required this.name,
    required this.rollNo,
    required this.department,
    required this.attendance,
    required this.feeStatus,
  });
}
