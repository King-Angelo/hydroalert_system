import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:firebaseapis/firestore/v1.dart' as firestore_v1;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:hydroalert_backend_api/src/firebase_admin_service.dart';
import 'package:hydroalert_backend_api/src/request_helpers.dart';

/// POST /cron/backup-export — starts a Firestore export to GCS.
/// Requires X-Cron-Secret. Uses BACKUP_BUCKET env (e.g. gs://hydroalert-dev-backups).
Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => methodNotAllowed(),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final bucket = Platform.environment['BACKUP_BUCKET'];
  if (bucket == null || bucket.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': 'server_error',
        'message': 'BACKUP_BUCKET environment variable is not set.',
      },
    );
  }

  final path = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
  if (path == null || path.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': 'server_error',
        'message':
            'GOOGLE_APPLICATION_CREDENTIALS must be set for Firestore export.',
      },
    );
  }

  final file = File(path);
  if (!await file.exists()) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': 'server_error',
        'message': 'Service account file not found.',
      },
    );
  }

  try {
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final credentials = auth.ServiceAccountCredentials.fromJson(json);

    final client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    try {
      final projectId = FirebaseAdminService.projectId;
      final dbName = 'projects/$projectId/databases/(default)';
      final now = DateTime.now().toUtc();
      final dateSuffix =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final prefix =
          bucket.endsWith('/') ? '${bucket}export-$dateSuffix' : '$bucket/export-$dateSuffix';

      final api = firestore_v1.FirestoreApi(client);
      final request = firestore_v1.GoogleFirestoreAdminV1ExportDocumentsRequest(
        outputUriPrefix: prefix,
      );

      final op = await api.projects.databases.exportDocuments(request, dbName);

      return Response.json(
        statusCode: HttpStatus.accepted,
        body: {
          'status': 'started',
          'operation': op.name,
          'output_uri_prefix': prefix,
          'message':
              'Firestore export started. Check Cloud Console for completion.',
        },
      );
    } finally {
      client.close();
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': 'server_error',
        'message': e.toString(),
      },
    );
  }
}
