import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hydroalert_backend_api/src/observability_log.dart';

/// CORS for browser-based admin app → API (e.g. Flutter web).
///
/// Set `CORS_ALLOW_ORIGIN` to a single origin in production (e.g. your admin URL).
/// If unset, reflects the request `Origin` or falls back to `*`.
///
/// Structured JSON request logs: `OPS_STRUCTURED_LOGS=false` to disable.
Handler middleware(Handler handler) {
  return (context) async {
    final cors = _corsHeaders(context.request.headers['origin']);

    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: HttpStatus.noContent, headers: cors);
    }

    final sw = Stopwatch()..start();
    final path = context.request.uri.path;
    final method = context.request.method.name;

    try {
      final response = await handler(context);
      sw.stop();
      ObservabilityLog.httpRequest(
        method: method,
        path: path,
        statusCode: response.statusCode,
        durationMs: sw.elapsedMilliseconds,
      );
      final merged = <String, Object>{
        for (final e in response.headers.entries) e.key: e.value,
        ...cors,
      };
      return response.copyWith(headers: merged);
    } catch (e, st) {
      sw.stop();
      ObservabilityLog.emit({
        'kind': 'http_error',
        'method': method,
        'path': path,
        'duration_ms': sw.elapsedMilliseconds,
        'error': e.toString(),
        'stack': st.toString(),
      });
      rethrow;
    }
  };
}

Map<String, Object> _corsHeaders(String? requestOrigin) {
  final allow = _allowOrigin(requestOrigin);
  return {
    'Access-Control-Allow-Origin': allow,
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type, X-Cron-Secret',
    'Access-Control-Max-Age': '86400',
  };
}

String _allowOrigin(String? requestOrigin) {
  final fixed = Platform.environment['CORS_ALLOW_ORIGIN']?.trim();
  if (fixed != null && fixed.isNotEmpty) {
    return fixed;
  }
  final o = requestOrigin?.trim();
  if (o != null && o.isNotEmpty) {
    return o;
  }
  return '*';
}
