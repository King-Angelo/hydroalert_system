import 'package:hydroalert_backend_api/src/manual_override_validation.dart';
import 'package:test/test.dart';

void main() {
  group('validateManualOverrideBody', () {
    test('null body', () {
      expect(
        validateManualOverrideBody(null),
        equals('Request body must be valid JSON object.'),
      );
    });

    test('invalid severity', () {
      expect(
        validateManualOverrideBody({
          'severity': 'Extreme',
          'message': 'x',
          'targetZone': 'Z1',
        }),
        equals('severity must be one of: Normal, Advisory, Watch, Warning.'),
      );
    });

    test('missing message', () {
      expect(
        validateManualOverrideBody({
          'severity': 'Watch',
          'targetZone': 'Z1',
        }),
        equals('message is required.'),
      );
    });

    test('valid payload', () {
      expect(
        validateManualOverrideBody({
          'severity': 'Watch',
          'message': 'River rising',
          'targetZone': 'District 1',
        }),
        isNull,
      );
    });
  });
}
