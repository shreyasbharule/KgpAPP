import 'package:flutter/material.dart';
import 'package:login_app_page/app/features/auth/login_screen.dart';

class UniversityStudentApp extends StatelessWidget {
  const UniversityStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'University Student App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004A99)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
