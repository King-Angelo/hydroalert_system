import 'package:dart_frog/dart_frog.dart';

import 'package:hydroalert_backend_api/src/request_helpers.dart';

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
  if (shelterId == null) return badRequest('shelterId is required.');

  final adminUid = context.read<String>();
  return scaffoldAccepted(
    operation: 'shelters.softDelete',
    adminUid: adminUid,
    payload: {
      'shelterId': shelterId,
    },
  );
}
