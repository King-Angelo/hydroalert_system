import 'package:http/http.dart' as http;

import '../../../core/api/admin_authenticated_http_client.dart';

/// Calls `POST /v1/alerts/manual-override` with the admin Firebase ID token.
class ManualOverrideApiClient {
  ManualOverrideApiClient({
    required String baseUrl,
    required Future<String?> Function() getIdToken,
    this.onUnauthorized,
    http.Client? httpClient,
  })  : _http = AdminAuthenticatedHttpClient(
          baseUrl: baseUrl,
          getIdToken: getIdToken,
          onUnauthorized: onUnauthorized,
          httpClient: httpClient,
        ),
        _ownsHttp = true;

  /// Reuses [http] (e.g. from [main]); do not call [close] on the shared client here.
  ManualOverrideApiClient.withSharedHttp(AdminAuthenticatedHttpClient http)
    : _http = http,
      _ownsHttp = false,
      onUnauthorized = null;

  /// Passed only for the default constructor; shared instance ignores this field.
  final Future<void> Function()? onUnauthorized;

  final AdminAuthenticatedHttpClient _http;
  final bool _ownsHttp;

  /// Returns decoded JSON body on success; throws on network / non-2xx.
  Future<Map<String, dynamic>> sendManualOverride({
    required String severity,
    required String message,
    required String targetZone,
  }) async {
    try {
      return await _http.postJson('/v1/alerts/manual-override', {
        'severity': severity,
        'message': message,
        'targetZone': targetZone.trim(),
      });
    } on AdminApiHttpException catch (e) {
      throw ManualOverrideApiException(e.statusCode, e.message);
    }
  }

  void close() {
    if (_ownsHttp) {
      _http.close();
    }
  }
}

class ManualOverrideApiException implements Exception {
  ManualOverrideApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ManualOverrideApiException($statusCode): $message';
}
