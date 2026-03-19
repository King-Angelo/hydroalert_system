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

  final reportId = readString(body['reportId']);
  final decision = readString(body['decision'])?.toLowerCase();
  final reviewNotes = readString(body['reviewNotes']) ?? '';

  if (reportId == null) return badRequest('reportId is required.');
  if (decision != 'validated' && decision != 'rejected') {
    return badRequest('decision must be validated or rejected.');
  }
  if (decision == 'rejected' && reviewNotes.isEmpty) {
    return badRequest('reviewNotes is required when decision is rejected.');
  }

  final adminUid = context.read<String>();
  return scaffoldAccepted(
    operation: 'reports.review',
    adminUid: adminUid,
    payload: {
      'reportId': reportId,
      'decision': decision,
      'reviewNotes': reviewNotes,
    },
  );
}
