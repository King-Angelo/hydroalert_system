import 'package:cloud_firestore/cloud_firestore.dart';

import 'iot_devices_repository.dart';

class FirestoreIotDevicesRepository implements IotDevicesRepository {
  FirestoreIotDevicesRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _collection = 'IoT_Devices';

  @override
  Stream<List<IotDeviceRow>> watchDevices() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map(_mapDoc).toList();
    });
  }

  IotDeviceRow _mapDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final id = (data['device_id'] as String?)?.trim().isNotEmpty == true
        ? (data['device_id'] as String).trim()
        : doc.id;
    final name = (data['name'] as String?)?.trim() ?? id;
    final zone = (data['zone'] as String?)?.trim() ?? '—';
    final isActive = data['is_active'] != false;

    DateTime? lastSeen;
    final ls = data['last_seen_at'];
    if (ls is Timestamp) lastSeen = ls.toDate();

    List<double>? levels;
    final latest = data['latest_reading'];
    if (latest is Map<String, dynamic>) {
      final raw = latest['water_level_cm'];
      if (raw is List) {
        levels = raw
            .map((e) => (e is num) ? e.toDouble() : double.tryParse('$e') ?? 0)
            .toList();
        if (levels.isEmpty) levels = null;
      }
    }

    final fw = (data['firmware_version'] as String?)?.trim();

    return IotDeviceRow(
      deviceId: id,
      name: name,
      zone: zone,
      isActive: isActive,
      lastSeenAt: lastSeen,
      waterLevelCm: levels,
      firmwareVersion: fw,
    );
  }
}
