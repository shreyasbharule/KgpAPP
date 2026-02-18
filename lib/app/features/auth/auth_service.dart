import 'package:login_app_page/app/core/api_client.dart';
import 'package:login_app_page/app/core/secure_token_store.dart';

class AuthService {
  AuthService(this._apiClient, this._tokenStore);

  final ApiClient _apiClient;
  final SecureTokenStore _tokenStore;

  Future<void> login(String email, String password) async {
    final response = await _apiClient.post('/api/v1/auth/login', {
      'email': email,
      'password': password,
    });

    final token = response['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Invalid authentication response');
    }

    await _tokenStore.save(token);
  }
}
