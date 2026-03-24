import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin_plus/firestore.dart';

import 'package:hydroalert_backend_api/src/alert_notification_service.dart';
import 'package:hydroalert_backend_api/src/firebase_admin_service.dart';
import 'package:hydroalert_backend_api/src/observability_log.dart';
import 'package:hydroalert_backend_api/src/request_helpers.dart';
import 'package:hydroalert_backend_api/src/v1_firestore_writes.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => methodNotAllowed(),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final body = await readJsonBody(context);
  if (body == null) return badRequest('Request body must be valid JSON object.');

  final severity = readString(body['severity']);
  final message = readString(body['message']);
  final targetZone = readString(body['targetZone']);

  const validSeverities = {'Normal', 'Advisory', 'Watch', 'Warning'};
  if (severity == null || !validSeverities.contains(severity)) {
    return badRequest('severity must be one of: Normal, Advisory, Watch, Warning.');
  }
  if (message == null) return badRequest('message is required.');
  if (targetZone == null) return badRequest('targetZone is required.');

  final adminUid = context.read<String>();

  final sw = Stopwatch()..start();
  try {
    final firestore = await V1FirestoreWrites.db();
    final messaging = await FirebaseAdminService.instance.getMessaging();

    final push = await AlertNotificationService.sendManualOverrideToZone(
      firestore: firestore,
      messaging: messaging,
      adminUid: adminUid,
      targetZone: targetZone,
      severity: severity,
      message: message,
    );

    final logRef = firestore.collection(V1FirestoreWrites.systemLogs).doc();
    sw.stop();
    final processingMs = sw.elapsedMilliseconds;
    final pushLog = {
      ...push.toLogMap(),
      'manual_override_processing_ms': processingMs,
    };

    await logRef.set({
      ...V1FirestoreWrites.systemLogBase(
        type: 'manual_override',
        action: 'alerts.manualOverride',
        adminId: adminUid,
      ),
      'severity': severity,
      'message': message,
      'target_zone': targetZone,
      'notes': message,
      'push': pushLog,
    });

    ObservabilityLog.manualOverrideCompleted(
      processingMs: processingMs,
      targetZone: targetZone,
      attempted: push.attempted,
    );

    return V1FirestoreWrites.ok({
      'status': 'ok',
      'operation': 'alerts.manualOverride',
      'severity': severity,
      'targetZone': targetZone,
      'push': pushLog,
    });
  } on FirebaseFirestoreAdminException catch (e) {
    return V1FirestoreWrites.firestoreFailure(e, StackTrace.current);
  } catch (e, st) {
    return V1FirestoreWrites.firestoreFailure(e, st);
  }
}
