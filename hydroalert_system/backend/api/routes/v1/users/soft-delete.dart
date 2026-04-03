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
  if (targetUserId == null) return badRequest('targetUserId is required.');

  final adminUid = context.read<String>();
  if (targetUserId == adminUid) {
    return V1FirestoreWrites.conflict('Cannot soft-delete your own account via this endpoint.');
  }

  try {
    final firestore = await V1FirestoreWrites.db();
    final userRef = firestore.collection(V1FirestoreWrites.users).doc(targetUserId);
    final snap = await userRef.get();
    if (!snap.exists) {
      return V1FirestoreWrites.notFound('User not found.');
    }

    final role = snap.data()?['user_type']?.toString().trim().toLowerCase();
    if (role == 'admin') {
      return V1FirestoreWrites.conflict(
        'Admin accounts cannot be modified from this endpoint.',
      );
    }

    final now = V1FirestoreWrites.tsNow();
    await userRef.update({
      'is_active': false,
      'deleted_at': now,
      'updated_at': now,
    });

    final logRef = firestore.collection(V1FirestoreWrites.systemLogs).doc();
    await logRef.set({
      ...V1FirestoreWrites.systemLogBase(
        type: 'user_management_action',
        action: 'users.softDelete',
        adminId: adminUid,
      ),
      'target_user_id': targetUserId,
      'after': {'is_active': false},
    });

    return V1FirestoreWrites.ok({
      'status': 'ok',
      'operation': 'users.softDelete',
      'targetUserId': targetUserId,
    });
  } on FirebaseFirestoreAdminException catch (e) {
    return V1FirestoreWrites.firestoreFailure(e, StackTrace.current);
  } catch (e, st) {
    return V1FirestoreWrites.firestoreFailure(e, st);
  }
}
