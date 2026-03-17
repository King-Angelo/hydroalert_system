import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Map<String, dynamic>?> readJsonBody(RequestContext context) async {
  final raw = await context.request.body();
  if (raw.trim().isEmpty) return <String, dynamic>{};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  } catch (_) {
    return null;
  }
}

String? readString(dynamic value) {
  if (value is! String) return null;
  final text = value.trim();
  return text.isEmpty ? null : text;
}

int? readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

Response methodNotAllowed() {
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Response badRequest(String message) {
  return Response.json(
    statusCode: HttpStatus.badRequest,
    body: {
      'error': 'bad_request',
      'message': message,
    },
  );
}

Response scaffoldAccepted({
  required String operation,
  required String adminUid,
  required Map<String, dynamic> payload,
}) {
  return Response.json(
    statusCode: HttpStatus.accepted,
    body: {
      'status': 'scaffolded',
      'operation': operation,
      'admin_uid': adminUid,
      'message': 'Endpoint contract validated. Firestore mutation layer pending.',
      'payload': payload,
    },
  );
}
