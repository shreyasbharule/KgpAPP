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
