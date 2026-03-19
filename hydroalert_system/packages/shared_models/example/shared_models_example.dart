import 'package:shared_models/shared_models.dart';

void main() {
  final reading = WaterLevelReading(
    id: 'reading-001',
    deviceId: 'node-728-a',
    recordedAt: DateTime.utc(2026, 3, 12, 8, 30),
    waterLevelMeters: 4.8,
    zoneId: 'zone-728-1',
    batteryVoltage: 3.7,
    rssi: -67,
  );

  final alert = FloodAlert(
    id: 'alert-001',
    zoneId: 'zone-728-1',
    level: reading.inferredAlertLevel,
    title: 'Water level rising',
    message: 'Please prepare for possible evacuation.',
    createdAt: DateTime.utc(2026, 3, 12, 8, 31),
    isActive: true,
    triggeredByReadingId: reading.id,
  );

  print('reading: ${reading.toJson()}');
  print('alert: ${alert.toJson()}');
}
