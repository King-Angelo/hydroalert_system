import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin_plus/firestore.dart';

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

  static Response firestoreFailure(Object e, StackTrace st) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'error': 'firestore_error',
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
