import 'package:hydroalert_backend_api/src/process_clock.dart';
import 'package:test/test.dart';

void main() {
  test('uptime seconds is non-negative', () {
    expect(hydroalertUptimeSeconds(), greaterThanOrEqualTo(0));
  });
}
