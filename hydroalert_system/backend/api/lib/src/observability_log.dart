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
    final payload = <String, Object?>{
      'ts': DateTime.now().toUtc().toIso8601String(),
      'service': 'hydroalert-backend-api',
      ...event,
    };
    stdout.writeln(jsonEncode(payload));
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
}
