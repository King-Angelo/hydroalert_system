import '../enums/geofence_event_type.dart';
import '../value_objects/lat_lng_point.dart';

class GeofenceEvent {
  const GeofenceEvent({
    required this.id,
    required this.zoneId,
    required this.userId,
    required this.eventType,
    required this.occurredAt,
    required this.location,
  });

  final String id;
  final String zoneId;
  final String userId;
  final GeofenceEventType eventType;
  final DateTime occurredAt;
  final LatLngPoint location;

  factory GeofenceEvent.fromJson(Map<String, dynamic> json) {
    return GeofenceEvent(
      id: _requiredString(json, 'id'),
      zoneId: _requiredString(json, 'zoneId'),
      userId: _requiredString(json, 'userId'),
      eventType: geofenceEventTypeFromJson(_requiredString(json, 'eventType')),
      occurredAt: _requiredDateTime(json, 'occurredAt'),
      location: LatLngPoint.fromJson(_requiredMap(json, 'location')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'userId': userId,
      'eventType': geofenceEventTypeToJson(eventType),
      'occurredAt': occurredAt.toUtc().toIso8601String(),
      'location': location.toJson(),
    };
  }

  GeofenceEvent copyWith({
    String? id,
    String? zoneId,
    String? userId,
    GeofenceEventType? eventType,
    DateTime? occurredAt,
    LatLngPoint? location,
  }) {
    return GeofenceEvent(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      userId: userId ?? this.userId,
      eventType: eventType ?? this.eventType,
      occurredAt: occurredAt ?? this.occurredAt,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is GeofenceEvent &&
            other.id == id &&
            other.zoneId == zoneId &&
            other.userId == userId &&
            other.eventType == eventType &&
            other.occurredAt == occurredAt &&
            other.location == location);
  }

  @override
  int get hashCode =>
      Object.hash(id, zoneId, userId, eventType, occurredAt, location);
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) throw FormatException('Missing "$field"');
  final text = value.toString().trim();
  if (text.isEmpty) throw FormatException('Empty "$field"');
  return text;
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Invalid "$field": $value');
}

DateTime _requiredDateTime(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is String) return DateTime.parse(value);
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  throw FormatException('Invalid "$field": $value');
}
