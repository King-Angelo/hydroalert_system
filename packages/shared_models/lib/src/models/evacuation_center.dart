import '../value_objects/lat_lng_point.dart';

class EvacuationCenter {
  const EvacuationCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.capacity,
    required this.currentOccupancy,
    required this.isOpen,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String address;
  final LatLngPoint location;
  final int capacity;
  final int currentOccupancy;
  final bool isOpen;
  final DateTime updatedAt;

  bool get isAtCapacity => currentOccupancy >= capacity;

  factory EvacuationCenter.fromJson(Map<String, dynamic> json) {
    return EvacuationCenter(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      address: _requiredString(json, 'address'),
      location: LatLngPoint.fromJson(_requiredMap(json, 'location')),
      capacity: _requiredInt(json, 'capacity'),
      currentOccupancy: _requiredInt(json, 'currentOccupancy'),
      isOpen: _requiredBool(json, 'isOpen'),
      updatedAt: _requiredDateTime(json, 'updatedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location.toJson(),
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'isOpen': isOpen,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  EvacuationCenter copyWith({
    String? id,
    String? name,
    String? address,
    LatLngPoint? location,
    int? capacity,
    int? currentOccupancy,
    bool? isOpen,
    DateTime? updatedAt,
  }) {
    return EvacuationCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      isOpen: isOpen ?? this.isOpen,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EvacuationCenter &&
            other.id == id &&
            other.name == name &&
            other.address == address &&
            other.location == location &&
            other.capacity == capacity &&
            other.currentOccupancy == currentOccupancy &&
            other.isOpen == isOpen &&
            other.updatedAt == updatedAt);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    address,
    location,
    capacity,
    currentOccupancy,
    isOpen,
    updatedAt,
  );
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

int _requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
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

DateTime _requiredDateTime(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is String) return DateTime.parse(value);
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  throw FormatException('Invalid "$field": $value');
}
