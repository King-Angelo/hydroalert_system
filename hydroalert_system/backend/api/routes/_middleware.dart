import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// CORS for browser-based admin app → API (e.g. Flutter web).
///
/// Set `CORS_ALLOW_ORIGIN` to a single origin in production (e.g. your admin URL).
/// If unset, reflects the request `Origin` or falls back to `*`.
Handler middleware(Handler handler) {
  return (context) async {
    final cors = _corsHeaders(context.request.headers['origin']);

    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: HttpStatus.noContent, headers: cors);
    }

    final response = await handler(context);
    final merged = <String, Object>{
      for (final e in response.headers.entries) e.key: e.value,
      ...cors,
    };
    return response.copyWith(headers: merged);
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
