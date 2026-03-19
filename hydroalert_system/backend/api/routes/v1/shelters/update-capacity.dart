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
  final nextCapacity = readInt(body['nextCapacity']);
  if (shelterId == null) return badRequest('shelterId is required.');
  if (nextCapacity == null || nextCapacity < 0) {
    return badRequest('nextCapacity must be a non-negative integer.');
  }

  final adminUid = context.read<String>();
  return scaffoldAccepted(
    operation: 'shelters.updateCapacity',
    adminUid: adminUid,
    payload: {
      'shelterId': shelterId,
      'nextCapacity': nextCapacity,
    },
  );
}
