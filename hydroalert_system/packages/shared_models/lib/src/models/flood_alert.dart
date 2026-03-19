import '../enums/alert_level.dart';

class FloodAlert {
  const FloodAlert({
    required this.id,
    required this.zoneId,
    required this.level,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isActive,
    this.triggeredByReadingId,
  });

  final String id;
  final String zoneId;
  final AlertLevel level;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isActive;
  final String? triggeredByReadingId;

  factory FloodAlert.fromJson(Map<String, dynamic> json) {
    return FloodAlert(
      id: _requiredString(json, 'id'),
      zoneId: _requiredString(json, 'zoneId'),
      level: alertLevelFromJson(_requiredString(json, 'level')),
      title: _requiredString(json, 'title'),
      message: _requiredString(json, 'message'),
      createdAt: _requiredDateTime(json, 'createdAt'),
      isActive: _requiredBool(json, 'isActive'),
      triggeredByReadingId: _optionalString(json, 'triggeredByReadingId'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'level': alertLevelToJson(level),
      'title': title,
      'message': message,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'isActive': isActive,
      'triggeredByReadingId': triggeredByReadingId,
    };
  }

  FloodAlert copyWith({
    String? id,
    String? zoneId,
    AlertLevel? level,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isActive,
    String? triggeredByReadingId,
  }) {
    return FloodAlert(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      level: level ?? this.level,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      triggeredByReadingId: triggeredByReadingId ?? this.triggeredByReadingId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FloodAlert &&
            other.id == id &&
            other.zoneId == zoneId &&
            other.level == level &&
            other.title == title &&
            other.message == message &&
            other.createdAt == createdAt &&
            other.isActive == isActive &&
            other.triggeredByReadingId == triggeredByReadingId);
  }

  @override
  int get hashCode => Object.hash(
    id,
    zoneId,
    level,
    title,
    message,
    createdAt,
    isActive,
    triggeredByReadingId,
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

bool _requiredBool(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
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
