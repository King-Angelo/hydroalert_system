import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin_plus/firestore.dart';

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

  final reportId = readString(body['reportId']);
  final decision = readString(body['decision'])?.toLowerCase();
  final reviewNotes = readString(body['reviewNotes']) ?? '';

  if (reportId == null) return badRequest('reportId is required.');
  if (decision != 'validated' && decision != 'rejected') {
    return badRequest('decision must be validated or rejected.');
  }
  if (decision == 'rejected' && reviewNotes.isEmpty) {
    return badRequest('reviewNotes is required when decision is rejected.');
  }

  final adminUid = context.read<String>();
  final status = decision == 'validated' ? 'Validated' : 'Rejected';

  try {
    final firestore = await V1FirestoreWrites.db();
    final reportRef =
        firestore.collection(V1FirestoreWrites.incidentReports).doc(reportId);

    await firestore.runTransaction((tx) async {
      final snap = await tx.get(reportRef);
      final data = snap.data();
      if (data == null) {
        throw StateError('missing_report');
      }
      final rawStatus = data['status'];
      final current =
          rawStatus == null ? 'Pending' : rawStatus.toString().trim();
      if (current != 'Pending') {
        throw StateError('not_pending');
      }

      tx.update(reportRef, {
        'status': status,
        'reviewed_by': adminUid,
        'reviewed_at': V1FirestoreWrites.tsNow(),
        'review_notes': reviewNotes,
      });

      final logRef = firestore.collection(V1FirestoreWrites.systemLogs).doc();
      tx.set(logRef, {
        ...V1FirestoreWrites.systemLogBase(
          type: 'report_review',
          action: 'reports.review',
          adminId: adminUid,
        ),
        'target_report_id': reportId,
        'notes': reviewNotes,
        'after': {
          'status': status,
        },
      });
    });

    return V1FirestoreWrites.ok({
      'status': 'ok',
      'operation': 'reports.review',
      'reportId': reportId,
      'decision': status,
    });
  } on FirebaseFirestoreAdminException catch (e) {
    if (e.errorCode == FirestoreClientErrorCode.notFound) {
      return V1FirestoreWrites.notFound('Incident report not found.');
    }
    return V1FirestoreWrites.firestoreFailure(e, StackTrace.current);
  } catch (e, st) {
    if (e is StateError) {
      if (e.message == 'missing_report') {
        return V1FirestoreWrites.notFound('Incident report not found.');
      }
      if (e.message == 'not_pending') {
        return V1FirestoreWrites.conflict(
          'Report is not Pending; cannot review again via this endpoint.',
        );
      }
    }
    return V1FirestoreWrites.firestoreFailure(e, st);
  }
}
