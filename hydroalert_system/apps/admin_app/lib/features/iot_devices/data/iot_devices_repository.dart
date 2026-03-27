/// One IoT device row from `IoT_Devices/{id}`.
class IotDeviceRow {
  const IotDeviceRow({
    required this.deviceId,
    required this.name,
    required this.zone,
    required this.isActive,
    this.lastSeenAt,
    this.waterLevelCm,
    this.firmwareVersion,
    this.latitude,
    this.longitude,
  });

  final String deviceId;
  final String name;
  final String zone;
  final bool isActive;
  final DateTime? lastSeenAt;

  /// Latest snapshot: three channels in cm, or null if missing.
  final List<double>? waterLevelCm;
  final String? firmwareVersion;

  /// From Firestore `location.{lat,lng}` when present.
  final double? latitude;
  final double? longitude;

  bool get hasMapCoordinates =>
      latitude != null && longitude != null;
}

abstract class IotDevicesRepository {
  /// Live list of devices (unordered; UI may sort).
  Stream<List<IotDeviceRow>> watchDevices();
}
