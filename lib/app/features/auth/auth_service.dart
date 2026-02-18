import 'package:login_app_page/app/core/api_client.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/core/session_manager.dart';

class AuthService {
  AuthService(this._apiClient, this._sessionManager);

  final ApiClient _apiClient;
  final SessionManager _sessionManager;
  bool demoMode = false;

  UserRole _parseRole(String raw) {
    switch (raw.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'faculty':
      case 'staff':
        return UserRole.faculty;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  Future<UserSession> login(String email, String password) async {
    if (demoMode) {
      final role = _parseRole(email.startsWith('admin') ? 'admin' : (email.startsWith('faculty') ? 'faculty' : 'student'));
      final session = UserSession(
        user: AppUser(id: 'demo-user', name: 'Demo User', email: email, role: role),
        tokens: SessionTokens(
          accessToken: 'demo-access-token',
          refreshToken: 'demo-refresh-token',
          accessTokenExpiry: DateTime.now().add(const Duration(hours: 8)),
        ),
      );
      await _sessionManager.start(session);
      return session;
    }
    final response = await _apiClient.post(
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
    );

    final body = response.body;
    final user = body['user'] as Map<String, dynamic>;
    final expiresIn = (body['expires_in'] as num?)?.toInt() ?? 1800;

    final session = UserSession(
      user: AppUser(
        id: user['id'].toString(),
        name: user['name'] as String,
        email: user['email'] as String,
        role: _parseRole(user['role'] as String? ?? 'student'),
      ),
      tokens: SessionTokens(
        accessToken: body['access_token'] as String,
        refreshToken: body['refresh_token'] as String,
        accessTokenExpiry: DateTime.now().add(Duration(seconds: expiresIn)),
      ),
    );

    await _sessionManager.start(session);
    return session;
  }

  Future<SessionTokens?> refreshSession() async {
    final current = _sessionManager.currentSession;
    if (current == null) return null;

    if (demoMode) {
      final refreshed = SessionTokens(
        accessToken: 'demo-access-token-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: current.tokens.refreshToken,
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 8)),
      );
      await _sessionManager.updateTokens(refreshed);
      return refreshed;
    }

    final response = await _apiClient.post(
      '/api/v1/auth/refresh',
      body: {'refresh_token': current.tokens.refreshToken},
    );

    final expiresIn = (response.body['expires_in'] as num?)?.toInt() ?? 1800;
    final refreshed = SessionTokens(
      accessToken: response.body['access_token'] as String,
      refreshToken: response.body['refresh_token'] as String,
      accessTokenExpiry: DateTime.now().add(Duration(seconds: expiresIn)),
    );
    await _sessionManager.updateTokens(refreshed);
    return refreshed;
  }

  Future<void> logout() => _sessionManager.clear();
}
