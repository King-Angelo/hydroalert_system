import 'dart:io';

import 'package:dart_firebase_admin_plus/firestore.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:hydroalert_backend_api/src/firebase_admin_service.dart';
import 'package:hydroalert_backend_api/src/request_helpers.dart';

/// POST /cron/logs-retention — deletes System_Logs older than 90 days (configurable).
/// Requires X-Cron-Secret. Uses LOGS_RETENTION_DAYS env (default 90).
Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => methodNotAllowed(),
  };
}

Future<Response> _onPost(RequestContext context) async {
  const defaultDays = 90;
  final daysStr = Platform.environment['LOGS_RETENTION_DAYS'];
  final days = int.tryParse(daysStr ?? '') ?? defaultDays;
  if (days < 1) {
    return badRequest('LOGS_RETENTION_DAYS must be >= 1.');
  }

  final cutoff = DateTime.now().toUtc().subtract(Duration(days: days));
  final cutoffTimestamp = Timestamp.fromDate(cutoff);

  try {
    final firestore = await FirebaseAdminService.instance.getFirestore();
    final logsRef = firestore.collection('System_Logs');

    var totalDeleted = 0;
    const batchLimit = 500;

    while (true) {
      final query = logsRef
          .where('timestamp', WhereFilter.lessThan, cutoffTimestamp)
          .orderBy('timestamp')
          .limit(batchLimit);
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) break;

      for (final doc in snapshot.docs) {
        await doc.ref.delete();
        totalDeleted++;
      }
    }

    return Response.json(
      body: {
        'status': 'ok',
        'deleted': totalDeleted,
        'cutoff': cutoff.toIso8601String(),
        'message': 'System_Logs retention completed.',
      },
    );
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
