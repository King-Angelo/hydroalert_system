import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin_plus/firestore.dart';
import 'package:dart_firebase_admin_plus/messaging.dart';

import 'firebase_admin_service.dart';

/// Shared Firestore helpers for v1 admin routes.
class V1FirestoreWrites {
  V1FirestoreWrites._();

  static const incidentReports = 'Incident_Reports';
  static const users = 'Users';
  static const shelters = 'Shelters';
  static const systemLogs = 'System_Logs';

  static Future<Firestore> db() => FirebaseAdminService.instance.getFirestore();

  static Timestamp tsNow() => Timestamp.now();

  static Map<String, dynamic> systemLogBase({
    required String type,
    required String action,
    required String adminId,
  }) {
    return {
      'type': type,
      'action': action,
      'timestamp': tsNow(),
      'admin_id': adminId,
    };
  }

  /// Maps Admin SDK errors to JSON so the admin web snackbar / DevTools show the
  /// real cause (e.g. missing Firestore composite index URL, FCM sender mismatch).
  static Response firestoreFailure(Object e, StackTrace st) {
    if (e is FirebaseFirestoreAdminException) {
      final body = <String, dynamic>{
        'error': 'firestore_error',
        'message': '${e.code}: ${e.message}',
        'firestore_client_code': e.errorCode.code,
      };
      if (e.errorCode == FirestoreClientErrorCode.failedPrecondition) {
        body['hint'] =
            'If the message mentions an index, open the link in it or deploy '
            '`firestore.indexes.json` with: firebase deploy --only firestore:indexes '
            '(same Firebase project as FIREBASE_PROJECT_ID on Render).';
      }
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: body,
      );
    }
    if (e is FirebaseMessagingAdminException) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'error': 'messaging_error',
          'message': '${e.code}: ${e.message}',
          'messaging_client_code': e.errorCode.code,
          'hint':
              'Confirm Cloud Messaging API is enabled for the Firebase project '
              'and the service account can use FCM. Check FIREBASE_PROJECT_ID matches '
              'the project whose Web app issues ID tokens.',
        },
      );
    }
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': 'internal_error',
        'error_type': e.runtimeType.toString(),
        'message': e.toString(),
      },
    );
  }

  static Response ok(Map<String, dynamic> body) {
    return Response.json(statusCode: HttpStatus.ok, body: body);
  }

  static Response notFound(String message) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'not_found', 'message': message},
    );
  }

  static Response conflict(String message) {
    return Response.json(
      statusCode: HttpStatus.conflict,
      body: {'error': 'conflict', 'message': message},
    );
  }
}

/// Best-effort parse of Firestore int (may be [int] or [BigInt]).
int? readFirestoreInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is BigInt) return v.toInt();
  if (v is num) return v.toInt();
  return null;
}
