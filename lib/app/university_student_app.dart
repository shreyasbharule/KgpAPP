import 'package:flutter/material.dart';
import 'package:login_app_page/app/core/api_client.dart';
import 'package:login_app_page/app/core/app_theme.dart';
import 'package:login_app_page/app/core/cache_store.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/core/secure_token_store.dart';
import 'package:login_app_page/app/core/session_manager.dart';
import 'package:login_app_page/app/features/auth/auth_service.dart';
import 'package:login_app_page/app/features/auth/login_screen.dart';
import 'package:login_app_page/app/features/dashboard/home_shell.dart';
import 'package:login_app_page/app/features/institution/institution_screen.dart';
import 'package:login_app_page/app/features/institution/institution_service.dart';
import 'package:login_app_page/app/features/student/student_service.dart';
import 'package:login_app_page/app/features/student/student_services_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniversityStudentApp extends StatefulWidget {
  const UniversityStudentApp({super.key});

  @override
  State<UniversityStudentApp> createState() => _UniversityStudentAppState();
}

class _UniversityStudentAppState extends State<UniversityStudentApp> {
  late final SecureTokenStore _tokenStore;
  late final SessionManager _sessionManager;
  late final ApiClient _apiClient;
  late final AuthService _authService;
  InstitutionService? _institutionService;
  StudentService? _studentService;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _tokenStore = SecureTokenStore();
    _sessionManager = SessionManager(_tokenStore);
    _apiClient = ApiClient(
      sessionManager: _sessionManager,
      onRefreshToken: _handleTokenRefresh,
    );
    _authService = AuthService(_apiClient, _sessionManager);
    _bootstrap();
  }

  Future<SessionTokens?> _handleTokenRefresh() async {
    final current = _sessionManager.currentSession;
    if (current == null) return null;

    if (!current.tokens.isExpired) {
      return current.tokens;
    }

    return _authService.refreshSession();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _institutionService = InstitutionService(PublicCacheStore(prefs));
    _studentService = StudentService(StudentCacheStore());

    final savedTokens = await _tokenStore.readSession();
    if (savedTokens != null) {
      final placeholderUser = AppUser(
        id: 'saved-user',
        name: 'Returning Student',
        email: 'student@university.edu',
        role: UserRole.student,
      );
      await _sessionManager.start(UserSession(user: placeholderUser, tokens: savedTokens));
    }

    if (mounted) {
      setState(() => _bootstrapped = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootstrapped || _institutionService == null || _studentService == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return AnimatedBuilder(
      animation: _sessionManager,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'University Student App',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          home: _sessionManager.currentSession == null
              ? LoginScreen(
                  authService: _authService,
                  onLoggedIn: () => setState(() {}),
                )
              : HomeShell(
                  user: _sessionManager.currentSession!.user,
                  institutionScreen: InstitutionScreen(service: _institutionService!),
                  studentScreen: StudentServicesScreen(service: _studentService!),
                  onLogout: () async {
                    await _authService.logout();
                    setState(() {});
                  },
                ),
        );
      },
    );
  }
}
