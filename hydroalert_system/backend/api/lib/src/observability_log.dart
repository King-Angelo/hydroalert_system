import 'dart:convert';
import 'dart:io';

/// P1 **structured logs** to **stdout** (one JSON object per line).
/// Set `OPS_STRUCTURED_LOGS=false` to disable.
abstract final class ObservabilityLog {
  static bool get _enabled {
    final v = Platform.environment['OPS_STRUCTURED_LOGS']?.toLowerCase();
    if (v == null || v.isEmpty) return true;
    return v == '1' || v == 'true' || v == 'yes';
  }

  static void emit(Map<String, Object?> event) {
    if (!_enabled) return;
    try {
      final payload = <String, Object?>{
        'ts': DateTime.now().toUtc().toIso8601String(),
        'service': 'hydroalert-backend-api',
        ...event,
      };
      stdout.writeln(jsonEncode(payload));
    } catch (_) {
      // Logging must never fail the request or mask real errors.
    }
  }

  static void httpRequest({
    required String method,
    required String path,
    required int statusCode,
    required int durationMs,
  }) {
    emit({
      'kind': 'http_request',
      'method': method,
      'path': path,
      'status': statusCode,
      'duration_ms': durationMs,
    });
  }

  static void manualOverrideCompleted({
    required int processingMs,
    required String targetZone,
    required bool attempted,
  }) {
    emit({
      'kind': 'alert_manual_override',
      'processing_ms': processingMs,
      'target_zone': targetZone,
      'fcm_attempted': attempted,
    });
  }

  /// Emitted when [POST /v1/alerts/manual-override] returns 500. Route handlers
  /// return a response instead of rethrowing, so this is how failures show up
  /// in Render logs (search: `manual_override_failed` or `error_type`).
  static void manualOverrideFailed({
    required Object error,
    required StackTrace stackTrace,
  }) {
    emit({
      'kind': 'manual_override_failed',
      'error_type': error.runtimeType.toString(),
      'message': error.toString(),
      'stack': stackTrace.toString().split('\n').take(16).join('\n'),
    });
  }
}
