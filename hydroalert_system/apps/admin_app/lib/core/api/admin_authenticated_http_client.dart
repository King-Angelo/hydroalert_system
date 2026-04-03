import 'dart:convert';

import 'package:http/http.dart' as http;

/// HTTP client for Dart Frog [v1] routes: sends Firebase ID token as Bearer.
///
/// Used by [ManualOverrideApiClient] and repositories that call privileged APIs.
class AdminAuthenticatedHttpClient {
  AdminAuthenticatedHttpClient({
    required String baseUrl,
    required Future<String?> Function() getIdToken,
    this.onUnauthorized,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl.replaceAll(RegExp(r'/$'), ''),
        _getIdToken = getIdToken,
        _http = httpClient ?? http.Client(),
        _closeHttp = httpClient == null;

  /// Called when the API returns 401. Usually [AuthService.signOut].
  final Future<void> Function()? onUnauthorized;

  final String _baseUrl;
  final Future<String?> Function() _getIdToken;
  final http.Client _http;
  final bool _closeHttp;

  /// POST JSON to [path] starting with `/`, e.g. `/v1/reports/review`.
  ///
  /// Returns decoded JSON object on 2xx. Throws [AdminApiHttpException] on API errors.
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await _getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('No ID token — sign in with Firebase as admin.');
    }

    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalized');
    final resp = await _http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    Map<String, dynamic>? decoded;
    try {
      if (resp.body.isNotEmpty) {
        final raw = jsonDecode(resp.body);
        if (raw is Map<String, dynamic>) decoded = raw;
      }
    } catch (_) {}

    if (resp.statusCode == 401) {
      try {
        await onUnauthorized?.call();
      } catch (_) {}
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final msg = decoded?['message']?.toString() ?? resp.body;
      throw AdminApiHttpException(resp.statusCode, msg);
    }

    return decoded ?? <String, dynamic>{};
  }

  void close() {
    if (_closeHttp) {
      _http.close();
    }
  }
}

class AdminApiHttpException implements Exception {
  AdminApiHttpException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'AdminApiHttpException($statusCode): $message';
}
