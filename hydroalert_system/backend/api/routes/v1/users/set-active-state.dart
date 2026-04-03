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
  final isActive = body['isActive'];
  if (targetUserId == null) return badRequest('targetUserId is required.');
  if (isActive is! bool) return badRequest('isActive must be boolean.');

  final adminUid = context.read<String>();
  if (targetUserId == adminUid) {
    return V1FirestoreWrites.conflict('Cannot change your own active state via this endpoint.');
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

    final beforeActive = snap.data()?['is_active'] == true;
    final now = V1FirestoreWrites.tsNow();

    // Match admin_app Firestore SDK: deactivate sets deleted_at; activate clears it.
    final patch = <Object, Object?>{
      'is_active': isActive,
      'updated_at': now,
    };
    if (!isActive) {
      patch['deleted_at'] = now;
    } else {
      patch['deleted_at'] = FieldValue.delete;
    }
    await userRef.update(patch);

    final logRef = firestore.collection(V1FirestoreWrites.systemLogs).doc();
    await logRef.set({
      ...V1FirestoreWrites.systemLogBase(
        type: 'user_management_action',
        action: 'users.setActiveState',
        adminId: adminUid,
      ),
      'target_user_id': targetUserId,
      'before': {'is_active': beforeActive},
      'after': {'is_active': isActive},
    });

    return V1FirestoreWrites.ok({
      'status': 'ok',
      'operation': 'users.setActiveState',
      'targetUserId': targetUserId,
      'isActive': isActive,
    });
  } on FirebaseFirestoreAdminException catch (e) {
    return V1FirestoreWrites.firestoreFailure(e, StackTrace.current);
  } catch (e, st) {
    return V1FirestoreWrites.firestoreFailure(e, st);
  }
}
