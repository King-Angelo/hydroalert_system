import 'dart:convert';

import 'package:http/http.dart' as http;

/// Calls `POST /v1/alerts/manual-override` with the admin Firebase ID token.
class ManualOverrideApiClient {
  ManualOverrideApiClient({
    required String baseUrl,
    required Future<String?> Function() getIdToken,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl.replaceAll(RegExp(r'/$'), ''),
        _getIdToken = getIdToken,
        _http = httpClient ?? http.Client();

  final String _baseUrl;
  final Future<String?> Function() _getIdToken;
  final http.Client _http;

  /// Returns decoded JSON body on success; throws on network / non-2xx.
  Future<Map<String, dynamic>> sendManualOverride({
    required String severity,
    required String message,
    required String targetZone,
  }) async {
    final token = await _getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('No ID token — sign in with Firebase as admin.');
    }

    final uri = Uri.parse('$_baseUrl/v1/alerts/manual-override');
    final resp = await _http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'severity': severity,
        'message': message,
        'targetZone': targetZone.trim(),
      }),
    );

    Map<String, dynamic>? body;
    try {
      if (resp.body.isNotEmpty) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      }
    } catch (_) {}

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final msg = body?['message']?.toString() ?? resp.body;
      throw ManualOverrideApiException(resp.statusCode, msg);
    }

    return body ?? <String, dynamic>{};
  }

  void close() => _http.close();
}

class ManualOverrideApiException implements Exception {
  ManualOverrideApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ManualOverrideApiException($statusCode): $message';
}
