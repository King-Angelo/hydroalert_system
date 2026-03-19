import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'service': 'hydroalert-backend-api',
      'status': 'ok',
      'message': 'Dart Frog backend scaffold is running.',
    },
  );
}
