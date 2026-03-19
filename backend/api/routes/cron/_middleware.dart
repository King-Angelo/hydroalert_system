import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Middleware for /cron/* endpoints. Validates X-Cron-Secret against CRON_SECRET env var.
/// Used by external schedulers (cron-job.org, GitHub Actions) to trigger backup/retention.
Handler middleware(Handler handler) {
  return (context) async {
    final secret = context.request.headers['x-cron-secret'];
    final expected = Platform.environment['CRON_SECRET'];

    if (expected == null || expected.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'error': 'server_error',
          'message': 'CRON_SECRET is not configured.',
        },
      );
    }

    if (secret == null || secret != expected) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'error': 'unauthorized',
          'message': 'Invalid or missing X-Cron-Secret header.',
        },
      );
    }

    return handler(context);
  };
}
