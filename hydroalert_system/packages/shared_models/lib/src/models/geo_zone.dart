import '../value_objects/lat_lng_point.dart';

class GeoZone {
  const GeoZone({
    required this.id,
    required this.name,
    required this.polygon,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<LatLngPoint> polygon;
  final bool isActive;
  final DateTime createdAt;

  factory GeoZone.fromJson(Map<String, dynamic> json) {
    return GeoZone(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      polygon: _requiredPolygon(json, 'polygon'),
      isActive: _requiredBool(json, 'isActive'),
      createdAt: _requiredDateTime(json, 'createdAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'polygon': polygon.map((point) => point.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  GeoZone copyWith({
    String? id,
    String? name,
    List<LatLngPoint>? polygon,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return GeoZone(
      id: id ?? this.id,
      name: name ?? this.name,
      polygon: polygon ?? this.polygon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is GeoZone &&
            other.id == id &&
            other.name == name &&
            _listEquals(other.polygon, polygon) &&
            other.isActive == isActive &&
            other.createdAt == createdAt);
  }

  @override
  int get hashCode =>
      Object.hash(id, name, Object.hashAll(polygon), isActive, createdAt);
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) throw FormatException('Missing "$field"');
  final text = value.toString().trim();
  if (text.isEmpty) throw FormatException('Empty "$field"');
  return text;
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

List<LatLngPoint> _requiredPolygon(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! List) throw FormatException('Invalid "$field": $value');

  return value
      .map(
        (item) => LatLngPoint.fromJson(Map<String, dynamic>.from(item as Map)),
      )
      .toList();
}

bool _listEquals(List<LatLngPoint> a, List<LatLngPoint> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
