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

  final severity = readString(body['severity']);
  final message = readString(body['message']);
  final targetZone = readString(body['targetZone']);

  const validSeverities = {'Normal', 'Advisory', 'Watch', 'Warning'};
  if (severity == null || !validSeverities.contains(severity)) {
    return badRequest('severity must be one of: Normal, Advisory, Watch, Warning.');
  }
  if (message == null) return badRequest('message is required.');
  if (targetZone == null) return badRequest('targetZone is required.');

  final adminUid = context.read<String>();
  return scaffoldAccepted(
    operation: 'alerts.manualOverride',
    adminUid: adminUid,
    payload: {
      'severity': severity,
      'message': message,
      'targetZone': targetZone,
    },
  );
}
