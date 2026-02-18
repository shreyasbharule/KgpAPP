import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:login_app_page/app/core/config.dart';
import 'package:login_app_page/app/core/secure_token_store.dart';

class ApiClient {
  ApiClient(this._tokenStore);

  final SecureTokenStore _tokenStore;

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final token = await _tokenStore.read();
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final payload =
        response.body.isNotEmpty ? jsonDecode(response.body) as Map<String, dynamic> : <String, dynamic>{};

    if (response.statusCode >= 400) {
      throw Exception(payload['message'] ?? 'Request failed');
    }

    return payload;
  }
}
