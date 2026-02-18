import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:login_app_page/app/core/config.dart';
import 'package:login_app_page/app/core/models.dart';
import 'package:login_app_page/app/core/session_manager.dart';

class ApiRequest {
  ApiRequest({
    required this.method,
    required this.path,
    this.body,
    Map<String, String>? headers,
  }) : headers = headers ?? <String, String>{};

  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final Map<String, String> headers;
}

class ApiResponse {
  ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final dynamic body;
}

abstract class ApiInterceptor {
  Future<ApiRequest> onRequest(ApiRequest request) async => request;

  Future<ApiResponse> onResponse(ApiResponse response) async => response;

  Future<ApiResponse> onError(
    ApiRequest request,
    ApiResponse response,
    Future<ApiResponse> Function() retry,
  ) async {
    return response;
  }
}

class AuthInterceptor implements ApiInterceptor {
  AuthInterceptor(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    final accessToken = _sessionManager.currentSession?.tokens.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    request.headers['Content-Type'] = 'application/json';
    return request;
  }
}

class RefreshTokenInterceptor implements ApiInterceptor {
  RefreshTokenInterceptor(this._refreshTokens);

  final Future<SessionTokens?> Function() _refreshTokens;

  @override
  Future<ApiResponse> onError(
    ApiRequest request,
    ApiResponse response,
    Future<ApiResponse> Function() retry,
  ) async {
    if (response.statusCode != 401 || request.headers['x-retried'] == '1') {
      return response;
    }

    final refreshed = await _refreshTokens();
    if (refreshed == null) {
      return response;
    }

    request.headers['x-retried'] = '1';
    return retry();
  }
}

class ApiClient {
  ApiClient({
    required SessionManager sessionManager,
    required Future<SessionTokens?> Function() onRefreshToken,
    http.Client? httpClient,
  })  : _httpClient = httpClient ?? http.Client(),
        _interceptors = [
          AuthInterceptor(sessionManager),
          RefreshTokenInterceptor(onRefreshToken),
        ];

  final http.Client _httpClient;
  final List<ApiInterceptor> _interceptors;

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) {
    return _send(ApiRequest(method: 'POST', path: path, body: body));
  }

  Future<ApiResponse> get(String path) {
    return _send(ApiRequest(method: 'GET', path: path));
  }

  Future<ApiResponse> _send(ApiRequest request) async {
    ApiRequest workingRequest = request;
    for (final interceptor in _interceptors) {
      workingRequest = await interceptor.onRequest(workingRequest);
    }

    final uri = Uri.parse('${AppConfig.apiBaseUrl}${workingRequest.path}');
    final response = await _execute(workingRequest, uri);

    ApiResponse processed = response;
    for (final interceptor in _interceptors) {
      processed = await interceptor.onResponse(processed);
    }

    if (processed.statusCode >= 400) {
      for (final interceptor in _interceptors) {
        processed = await interceptor.onError(
          workingRequest,
          processed,
          () => _send(request),
        );
      }
    }

    if (processed.statusCode >= 400) {
      if (processed.body is Map<String, dynamic>) {
        throw Exception((processed.body as Map<String, dynamic>)['message'] ?? (processed.body as Map<String, dynamic>)['detail'] ?? 'Request failed');
      }
      throw Exception('Request failed');
    }

    return processed;
  }

  Future<ApiResponse> _execute(ApiRequest request, Uri uri) async {
    late http.Response raw;
    switch (request.method) {
      case 'POST':
        raw = await _httpClient.post(
          uri,
          headers: request.headers,
          body: request.body == null ? null : jsonEncode(request.body),
        );
        break;
      case 'GET':
        raw = await _httpClient.get(uri, headers: request.headers);
        break;
      default:
        throw UnsupportedError('Unsupported method ${request.method}');
    }

    final decoded = raw.body.isEmpty ? <String, dynamic>{} : jsonDecode(raw.body);

    return ApiResponse(statusCode: raw.statusCode, body: decoded);
  }
}
