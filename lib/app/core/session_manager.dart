import 'package:flutter/foundation.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/core/secure_token_store.dart';

class SessionManager extends ChangeNotifier {
  SessionManager(this._tokenStore);

  final SecureTokenStore _tokenStore;
  UserSession? _currentSession;

  UserSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession != null;
  bool get isAdmin => _currentSession?.user.role == UserRole.admin;

  Future<void> restore(AppUser user) async {
    final tokens = await _tokenStore.readSession();
    if (tokens == null) return;
    _currentSession = UserSession(user: user, tokens: tokens);
    notifyListeners();
  }

  Future<void> start(UserSession session) async {
    _currentSession = session;
    await _tokenStore.saveSession(session.tokens);
    notifyListeners();
  }

  Future<void> updateTokens(SessionTokens tokens) async {
    final session = _currentSession;
    if (session == null) return;
    _currentSession = UserSession(user: session.user, tokens: tokens);
    await _tokenStore.saveSession(tokens);
    notifyListeners();
  }

  Future<void> clear() async {
    _currentSession = null;
    await _tokenStore.clear();
    notifyListeners();
  }
}
