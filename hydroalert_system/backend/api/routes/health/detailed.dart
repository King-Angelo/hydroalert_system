import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hydroalert_backend_api/src/firebase_admin_service.dart';
import 'package:hydroalert_backend_api/src/process_clock.dart';

/// Extended health for uptime checks and admin dashboards (no auth).
///
/// `GET /health/detailed`
Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final version = Platform.environment['DEPLOY_VERSION']?.trim();
  final projectId = FirebaseAdminService.projectId;

  return Response.json(
    body: {
      'status': 'healthy',
      'service': 'hydroalert-backend-api',
      'process_started_at': hydroalertProcessStartedAt.toIso8601String(),
      'uptime_seconds': hydroalertUptimeSeconds(),
      'firebase_project_id': projectId,
      if (version != null && version.isNotEmpty) 'deploy_version': version,
    },
  );
}
