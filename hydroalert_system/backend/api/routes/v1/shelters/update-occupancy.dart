import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin_plus/firestore.dart';

import 'package:hydroalert_backend_api/src/request_helpers.dart';
import 'package:hydroalert_backend_api/src/v1_firestore_writes.dart';
import 'package:hydroalert_backend_api/src/v1_shelter_document.dart';

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
  final nextOccupancy = readInt(body['nextOccupancy']);
  if (shelterId == null) return badRequest('shelterId is required.');
  if (nextOccupancy == null || nextOccupancy < 0) {
    return badRequest('nextOccupancy must be a non-negative integer.');
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
    if (!v1ShelterIsActive(data)) {
      return V1FirestoreWrites.conflict('Shelter is inactive (soft-deleted).');
    }

    final capacity = v1ShelterCapacity(data);
    if (capacity > 0 && nextOccupancy > capacity) {
      return badRequest(
        'nextOccupancy ($nextOccupancy) cannot exceed capacity ($capacity).',
      );
    }

    final currentOcc = v1ShelterOccupancy(data);
    if (currentOcc == nextOccupancy) {
      return V1FirestoreWrites.ok({
        'status': 'ok',
        'operation': 'shelters.updateOccupancy',
        'shelterId': shelterId,
        'nextOccupancy': nextOccupancy,
        'message': 'No change.',
      });
    }

    final now = V1FirestoreWrites.tsNow();
    await ref.update({
      'current_occupancy': nextOccupancy,
      'updated_at': now,
      'shelter_details.current_occupancy': nextOccupancy,
      'shelter_details.updated_at': now,
    });

    final logRef = firestore.collection(V1FirestoreWrites.systemLogs).doc();
    await logRef.set({
      ...V1FirestoreWrites.systemLogBase(
        type: 'shelter_update',
        action: 'shelters.updateOccupancy',
        adminId: adminUid,
      ),
      'target_shelter_id': shelterId,
      'before': {'current_occupancy': currentOcc},
      'after': {'current_occupancy': nextOccupancy},
    });

    return V1FirestoreWrites.ok({
      'status': 'ok',
      'operation': 'shelters.updateOccupancy',
      'shelterId': shelterId,
      'nextOccupancy': nextOccupancy,
    });
  } on FirebaseFirestoreAdminException catch (e) {
    return V1FirestoreWrites.firestoreFailure(e, StackTrace.current);
  } catch (e, st) {
    return V1FirestoreWrites.firestoreFailure(e, st);
  }
}
