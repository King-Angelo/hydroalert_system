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
  final nextStatus = readString(body['nextStatus']);
  if (shelterId == null) return badRequest('shelterId is required.');
  if (nextStatus != 'Open' && nextStatus != 'Closed') {
    return badRequest('nextStatus must be Open or Closed.');
  }

  final adminUid = context.read<String>();
  return scaffoldAccepted(
    operation: 'shelters.updateStatus',
    adminUid: adminUid,
    payload: {
      'shelterId': shelterId,
      'nextStatus': nextStatus,
    },
  );
}
