import '../enums/alert_level.dart';

class WaterLevelReading {
  const WaterLevelReading({
    required this.id,
    required this.deviceId,
    required this.recordedAt,
    required this.waterLevelMeters,
    this.zoneId,
    this.batteryVoltage,
    this.rssi,
  });

  final String id;
  final String deviceId;
  final DateTime recordedAt;
  final double waterLevelMeters;
  final String? zoneId;
  final double? batteryVoltage;
  final int? rssi;

  AlertLevel get inferredAlertLevel =>
      alertLevelFromWaterLevelMeters(waterLevelMeters);

  factory WaterLevelReading.fromJson(Map<String, dynamic> json) {
    return WaterLevelReading(
      id: _requiredString(json, 'id'),
      deviceId: _requiredString(json, 'deviceId'),
      recordedAt: _requiredDateTime(json, 'recordedAt'),
      waterLevelMeters: _requiredDouble(json, 'waterLevelMeters'),
      zoneId: _optionalString(json, 'zoneId'),
      batteryVoltage: _optionalDouble(json, 'batteryVoltage'),
      rssi: _optionalInt(json, 'rssi'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'recordedAt': recordedAt.toUtc().toIso8601String(),
      'waterLevelMeters': waterLevelMeters,
      'zoneId': zoneId,
      'batteryVoltage': batteryVoltage,
      'rssi': rssi,
    };
  }

  WaterLevelReading copyWith({
    String? id,
    String? deviceId,
    DateTime? recordedAt,
    double? waterLevelMeters,
    String? zoneId,
    double? batteryVoltage,
    int? rssi,
  }) {
    return WaterLevelReading(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      recordedAt: recordedAt ?? this.recordedAt,
      waterLevelMeters: waterLevelMeters ?? this.waterLevelMeters,
      zoneId: zoneId ?? this.zoneId,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      rssi: rssi ?? this.rssi,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is WaterLevelReading &&
            other.id == id &&
            other.deviceId == deviceId &&
            other.recordedAt == recordedAt &&
            other.waterLevelMeters == waterLevelMeters &&
            other.zoneId == zoneId &&
            other.batteryVoltage == batteryVoltage &&
            other.rssi == rssi);
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    recordedAt,
    waterLevelMeters,
    zoneId,
    batteryVoltage,
    rssi,
  );
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) throw FormatException('Missing "$field"');
  final text = value.toString().trim();
  if (text.isEmpty) throw FormatException('Empty "$field"');
  return text;
}

String? _optionalString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

double _requiredDouble(Map<String, dynamic> json, String field) {
  final value = json[field];
  final parsed = _parseDouble(value);
  if (parsed == null) throw FormatException('Invalid "$field": $value');
  return parsed;
}

double? _optionalDouble(Map<String, dynamic> json, String field) {
  return _parseDouble(json[field]);
}

int? _optionalInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

DateTime _requiredDateTime(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is String) return DateTime.parse(value);
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  throw FormatException('Invalid "$field": $value');
}
