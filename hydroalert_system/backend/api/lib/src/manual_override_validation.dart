import 'package:hydroalert_backend_api/src/request_helpers.dart';

/// Pure validation for `POST /v1/alerts/manual-override` (testable without HTTP).
///
/// Returns an English error message for [badRequest], or `null` if OK.
String? validateManualOverrideBody(Map<String, dynamic>? body) {
  if (body == null) {
    return 'Request body must be valid JSON object.';
  }

  final severity = readString(body['severity']);
  final message = readString(body['message']);
  final targetZone = readString(body['targetZone']);

  const validSeverities = {'Normal', 'Advisory', 'Watch', 'Warning'};
  if (severity == null || !validSeverities.contains(severity)) {
    return 'severity must be one of: Normal, Advisory, Watch, Warning.';
  }
  if (message == null) return 'message is required.';
  if (targetZone == null) return 'targetZone is required.';

  return null;
}
