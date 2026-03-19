import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('Alert level thresholds', () {
    test('maps water levels to expected alert levels', () {
      expect(alertLevelFromWaterLevelMeters(3.5), AlertLevel.normal);
      expect(alertLevelFromWaterLevelMeters(3.6), AlertLevel.advisory);
      expect(alertLevelFromWaterLevelMeters(4.5), AlertLevel.watch);
      expect(alertLevelFromWaterLevelMeters(6.0), AlertLevel.warning);
    });
  });

  group('WaterLevelReading', () {
    test('json round-trip and copyWith', () {
      final reading = WaterLevelReading(
        id: 'reading-001',
        deviceId: 'node-728-a',
        recordedAt: DateTime.utc(2026, 3, 12, 9, 0),
        waterLevelMeters: 4.7,
        zoneId: 'zone-728-1',
        batteryVoltage: 3.75,
        rssi: -70,
      );

      final json = reading.toJson();
      final fromJson = WaterLevelReading.fromJson(json);

      expect(fromJson, reading);
      expect(fromJson.inferredAlertLevel, AlertLevel.watch);

      final updated = reading.copyWith(waterLevelMeters: 6.1);
      expect(updated.inferredAlertLevel, AlertLevel.warning);
      expect(updated.id, reading.id);
    });
  });
}
