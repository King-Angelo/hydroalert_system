class LatLngPoint {
  const LatLngPoint({required this.latitude, required this.longitude})
    : assert(latitude >= -90 && latitude <= 90, 'Latitude out of range'),
      assert(longitude >= -180 && longitude <= 180, 'Longitude out of range');

  final double latitude;
  final double longitude;

  factory LatLngPoint.fromJson(Map<String, dynamic> json) {
    final rawLat = json['latitude'] ?? json['lat'];
    final rawLng = json['longitude'] ?? json['lng'] ?? json['lon'];

    return LatLngPoint(
      latitude: _toDouble(rawLat, field: 'latitude'),
      longitude: _toDouble(rawLng, field: 'longitude'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  LatLngPoint copyWith({double? latitude, double? longitude}) {
    return LatLngPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LatLngPoint &&
            other.latitude == latitude &&
            other.longitude == longitude);
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'LatLngPoint(latitude: $latitude, longitude: $longitude)';
}

double _toDouble(dynamic value, {required String field}) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Invalid "$field" value: $value');
}
