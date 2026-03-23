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

  final shelterId = readString(body['shelterId']);
  final nextCapacity = readInt(body['nextCapacity']);
  if (shelterId == null) return badRequest('shelterId is required.');
  if (nextCapacity == null || nextCapacity < 0) {
    return badRequest('nextCapacity must be a non-negative integer.');
  }

  final adminUid = context.read<String>();

  try {
    final firestore = await V1FirestoreWrites.db();
    final ref = firestore.collection(V1FirestoreWrites.shelters).doc(shelterId);
    final snap = await ref.get();
    if (!snap.exists) {
      return V1FirestoreWrites.notFound('Shelter not found.');
    }
    final data = snap.data()!;
    if (data['is_active'] == false) {
      return V1FirestoreWrites.conflict('Shelter is inactive (soft-deleted).');
    }

    final currentOcc = readFirestoreInt(data['current_occupancy']) ?? 0;
    if (nextCapacity < currentOcc) {
      return badRequest(
        'nextCapacity ($nextCapacity) cannot be less than current '
        'occupancy ($currentOcc).',
      );
    }

    final before = readFirestoreInt(data['capacity']);
    await ref.update({
      'capacity': nextCapacity,
      'updated_at': V1FirestoreWrites.tsNow(),
    });

    final logRef = firestore.collection(V1FirestoreWrites.systemLogs).doc();
    await logRef.set({
      ...V1FirestoreWrites.systemLogBase(
        type: 'shelter_update',
        action: 'shelters.updateCapacity',
        adminId: adminUid,
      ),
      'target_shelter_id': shelterId,
      'before': {'capacity': before},
      'after': {'capacity': nextCapacity},
    });

    return V1FirestoreWrites.ok({
      'status': 'ok',
      'operation': 'shelters.updateCapacity',
      'shelterId': shelterId,
      'nextCapacity': nextCapacity,
    });
  } on FirebaseFirestoreAdminException catch (e) {
    return V1FirestoreWrites.firestoreFailure(e, StackTrace.current);
  } catch (e, st) {
    return V1FirestoreWrites.firestoreFailure(e, st);
  }
}
