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

  final targetUserId = readString(body['targetUserId']);
  final nextRole = readString(body['nextRole'])?.toLowerCase();
  if (targetUserId == null) return badRequest('targetUserId is required.');
  if (nextRole != 'official' && nextRole != 'resident') {
    return badRequest('nextRole must be official or resident.');
  }

  final adminUid = context.read<String>();
  if (targetUserId == adminUid) {
    return V1FirestoreWrites.conflict('Cannot change your own role via this endpoint.');
  }

  try {
    final firestore = await V1FirestoreWrites.db();
    final userRef = firestore.collection(V1FirestoreWrites.users).doc(targetUserId);
    final snap = await userRef.get();
    if (!snap.exists) {
      return V1FirestoreWrites.notFound('User not found.');
    }

    final beforeType = snap.data()?['user_type']?.toString();
    final beforeNorm = beforeType?.trim().toLowerCase();
    if (beforeNorm == 'admin') {
      return V1FirestoreWrites.conflict(
        'Admin accounts cannot be modified from this endpoint.',
      );
    }

    await userRef.update({
      'user_type': nextRole,
      'updated_at': V1FirestoreWrites.tsNow(),
    });

    final logRef = firestore.collection(V1FirestoreWrites.systemLogs).doc();
    await logRef.set({
      ...V1FirestoreWrites.systemLogBase(
        type: 'user_management_action',
        action: 'users.updateRole',
        adminId: adminUid,
      ),
      'target_user_id': targetUserId,
      'before': {'user_type': beforeType},
      'after': {'user_type': nextRole},
    });

    return V1FirestoreWrites.ok({
      'status': 'ok',
      'operation': 'users.updateRole',
      'targetUserId': targetUserId,
      'nextRole': nextRole,
    });
  } on FirebaseFirestoreAdminException catch (e) {
    return V1FirestoreWrites.firestoreFailure(e, StackTrace.current);
  } catch (e, st) {
    return V1FirestoreWrites.firestoreFailure(e, st);
  }
}
