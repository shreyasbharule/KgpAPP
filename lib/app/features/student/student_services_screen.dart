import 'package:flutter/material.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/features/student/student_service.dart';

class StudentServicesScreen extends StatefulWidget {
  const StudentServicesScreen({super.key, required this.service});

  final StudentService service;

  @override
  State<StudentServicesScreen> createState() => _StudentServicesScreenState();
}

class _StudentServicesScreenState extends State<StudentServicesScreen> {
  late Future<StudentAcademicsBundle> _academicsFuture;

  @override
  void initState() {
    super.initState();
    _academicsFuture = widget.service.fetchAcademics();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentAcademicsBundle>(
      future: _academicsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load student data: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Timetable', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...data.timetable.map(
              (entry) => Card(
                child: ListTile(
                  title: Text('${entry.courseCode} • ${entry.courseName}'),
                  subtitle: Text(
                    '${entry.startsAt} - ${entry.endsAt}\n${entry.instructorName ?? 'Faculty TBD'} • ${entry.room ?? 'Room TBD'}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Grades (read-only)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...data.grades.map(
              (grade) => Card(
                child: ListTile(
                  title: Text('${grade.courseCode} • ${grade.courseName ?? 'Course'}'),
                  subtitle: Text('${grade.term} • Credits: ${grade.credits}'),
                  trailing: Text(grade.grade, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
