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

  final targetUserId = readString(body['targetUserId']);
  final nextRole = readString(body['nextRole'])?.toLowerCase();
  if (targetUserId == null) return badRequest('targetUserId is required.');
  if (nextRole != 'official' && nextRole != 'resident') {
    return badRequest('nextRole must be official or resident.');
  }

  final adminUid = context.read<String>();
  return scaffoldAccepted(
    operation: 'users.updateRole',
    adminUid: adminUid,
    payload: {
      'targetUserId': targetUserId,
      'nextRole': nextRole,
    },
  );
}
