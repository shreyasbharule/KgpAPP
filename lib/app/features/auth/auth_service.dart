import 'package:login_app_page/app/core/api_client.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/core/session_manager.dart';

class AuthService {
  AuthService(this._apiClient, this._sessionManager);

  final ApiClient _apiClient;
  final SessionManager _sessionManager;

  Future<UserSession> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/api/v1/auth/login',
          body: {'email': email, 'password': password});
      final body = response.body;
      final roleName = (body['role'] as String? ?? 'student').toLowerCase();
      final session = UserSession(
        user: AppUser(
          id: (body['id'] ?? 'u-1').toString(),
          name: body['name'] as String? ?? 'Student User',
          email: email,
          role: roleName == 'admin' ? UserRole.admin : UserRole.student,
        ),
        tokens: SessionTokens(
          accessToken: body['access_token'] as String,
          refreshToken: body['refresh_token'] as String? ?? 'refresh-token',
          accessTokenExpiry: DateTime.now().add(const Duration(minutes: 30)),
        ),
      );
      await _sessionManager.start(session);
      return session;
    } catch (_) {
      // Fallback mock auth for scaffold/demo.
      final isAdmin = email.toLowerCase().startsWith('admin');
      final session = UserSession(
        user: AppUser(
          id: isAdmin ? 'admin-1' : 'student-1',
          name: isAdmin ? 'Admin User' : 'Student User',
          email: email,
          role: isAdmin ? UserRole.admin : UserRole.student,
        ),
        tokens: SessionTokens(
          accessToken: 'demo-access-token',
          refreshToken: 'demo-refresh-token',
          accessTokenExpiry: DateTime.now().add(const Duration(minutes: 15)),
        ),
      );
      await _sessionManager.start(session);
      return session;
    }
  }

  Future<SessionTokens?> refreshSession() async {
    final current = _sessionManager.currentSession;
    if (current == null) return null;

    try {
      final response = await _apiClient.post('/api/v1/auth/refresh',
          body: {'refresh_token': current.tokens.refreshToken});
      final refreshed = SessionTokens(
        accessToken: response.body['access_token'] as String,
        refreshToken: response.body['refresh_token'] as String? ?? current.tokens.refreshToken,
        accessTokenExpiry: DateTime.now().add(const Duration(minutes: 30)),
      );
      await _sessionManager.updateTokens(refreshed);
      return refreshed;
    } catch (_) {
      final fallback = SessionTokens(
        accessToken: 'demo-access-token-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: current.tokens.refreshToken,
        accessTokenExpiry: DateTime.now().add(const Duration(minutes: 15)),
      );
      await _sessionManager.updateTokens(fallback);
      return fallback;
    }
  }

  Future<void> logout() => _sessionManager.clear();
}
