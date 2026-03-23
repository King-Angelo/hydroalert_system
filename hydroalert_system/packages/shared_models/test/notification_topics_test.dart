import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationTopics.slugifyZone', () {
    test('normalizes and strips unsafe chars', () {
      expect(NotificationTopics.slugifyZone('  District 12 / North  '), 'district_12_north');
      expect(NotificationTopics.slugifyZone('!!!'), 'unknown');
    });
  });
}
