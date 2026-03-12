import '../value_objects/lat_lng_point.dart';

class DeviceNode {
  const DeviceNode({
    required this.id,
    required this.name,
    required this.location,
    required this.isOnline,
    required this.lastSeenAt,
    this.batteryVoltage,
    this.firmwareVersion,
  });

  final String id;
  final String name;
  final LatLngPoint location;
  final bool isOnline;
  final DateTime lastSeenAt;
  final double? batteryVoltage;
  final String? firmwareVersion;

  factory DeviceNode.fromJson(Map<String, dynamic> json) {
    return DeviceNode(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      location: LatLngPoint.fromJson(_requiredMap(json, 'location')),
      isOnline: _requiredBool(json, 'isOnline'),
      lastSeenAt: _requiredDateTime(json, 'lastSeenAt'),
      batteryVoltage: _optionalDouble(json, 'batteryVoltage'),
      firmwareVersion: _optionalString(json, 'firmwareVersion'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location.toJson(),
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt.toUtc().toIso8601String(),
      'batteryVoltage': batteryVoltage,
      'firmwareVersion': firmwareVersion,
    };
  }

  DeviceNode copyWith({
    String? id,
    String? name,
    LatLngPoint? location,
    bool? isOnline,
    DateTime? lastSeenAt,
    double? batteryVoltage,
    String? firmwareVersion,
  }) {
    return DeviceNode(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DeviceNode &&
            other.id == id &&
            other.name == name &&
            other.location == location &&
            other.isOnline == isOnline &&
            other.lastSeenAt == lastSeenAt &&
            other.batteryVoltage == batteryVoltage &&
            other.firmwareVersion == firmwareVersion);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    isOnline,
    lastSeenAt,
    batteryVoltage,
    firmwareVersion,
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

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Invalid "$field": $value');
}

bool _requiredBool(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  throw FormatException('Invalid "$field": $value');
}

double? _optionalDouble(Map<String, dynamic> json, String field) {
  final value = json[field];
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
