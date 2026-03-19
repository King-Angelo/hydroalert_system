import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hydroalert_backend_api/src/firebase_admin_service.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(_adminAuthMiddleware());
}

Middleware _adminAuthMiddleware() {
  return (handler) {
    return (context) async {
      final authHeader = context.request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'error': 'unauthorized',
            'message': 'Missing Authorization: Bearer <token> header.',
          },
        );
      }

      final token = authHeader.substring(7).trim();
      if (token.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'error': 'unauthorized',
            'message': 'Empty Bearer token.',
          },
        );
      }

      try {
        final adminUid = await FirebaseAdminService.instance
            .verifyAndGetAdminUid(token);
        if (adminUid == null || adminUid.isEmpty) {
          return Response.json(
            statusCode: HttpStatus.forbidden,
            body: {
              'error': 'forbidden',
              'message':
                  'Invalid token or user is not an active admin. Verify Firebase ID token and Users/{uid} user_type, is_active.',
            },
          );
        }

        final next = context.provide<String>(() => adminUid);
        return handler(next);
      } on Exception catch (e) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'error': 'unauthorized',
            'message': 'Token verification failed: ${e.toString()}',
          },
        );
      }
    };
  };
}
