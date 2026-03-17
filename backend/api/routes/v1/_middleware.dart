import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

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

      // Scaffold-only header. Replace with Firebase token verification in P0 implementation.
      final adminUid = context.request.headers['x-admin-uid']?.trim();
      if (adminUid == null || adminUid.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.forbidden,
          body: {
            'error': 'forbidden',
            'message': 'Missing x-admin-uid header in scaffold mode.',
          },
        );
      }

      final next = context.provide<String>(() => adminUid);
      return handler(next);
    };
  };
}
