import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login_app_page/app/core/models.dart';

class SecureTokenStore {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'auth_session';

  Future<void> saveSession(SessionTokens session) {
    return _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  Future<SessionTokens?> readSession() async {
    final data = await _storage.read(key: _sessionKey);
    if (data == null || data.isEmpty) {
      return null;
    }

    return SessionTokens.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> clear() => _storage.delete(key: _sessionKey);
}
