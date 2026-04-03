import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/api/admin_authenticated_http_client.dart';
import 'shelter_logistics_repository.dart';

class FirestoreShelterLogisticsRepository implements ShelterLogisticsRepository {
  FirestoreShelterLogisticsRepository({
    required FirebaseFirestore firestore,
    AdminAuthenticatedHttpClient? privilegedApi,
  }) : _firestore = firestore,
       _privilegedApi = privilegedApi;

  final FirebaseFirestore _firestore;

  final AdminAuthenticatedHttpClient? _privilegedApi;

  static const _sheltersCollection = 'Shelters';
  static const _logsCollection = 'System_Logs';

  @override
  Stream<List<ShelterRecord>> watchShelters() {
    return _firestore.collection(_sheltersCollection).snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => _mapShelterDoc(doc.id, doc.data()))
          .toList()
        ..sort((a, b) {
          final byZone = (a.zone ?? '').compareTo(b.zone ?? '');
          if (byZone != 0) return byZone;
          return a.name.compareTo(b.name);
        });
      return items;
    });
  }

  @override
  Future<void> updateShelterStatus({
    required String shelterId,
    required String nextStatus,
    required String adminId,
  }) async {
    if (nextStatus != 'Open' && nextStatus != 'Closed') {
      throw ArgumentError('Status must be Open or Closed.');
    }

    final api = _privilegedApi;
    if (api != null) {
      await api.postJson('/v1/shelters/update-status', {
        'shelterId': shelterId,
        'nextStatus': nextStatus,
      });
      return;
    }

    final shelterRef = _firestore.collection(_sheltersCollection).doc(shelterId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(shelterRef);
      if (!snapshot.exists) throw StateError('Shelter not found: $shelterId');

      final data = snapshot.data()!;
      final details = _mapFrom(data['shelter_details']);
      final currentStatus = _trimmedString(details['status']) ??
          _trimmedString(data['status']) ??
          'Closed';
      if (currentStatus == nextStatus) return;

      _assertActive(details, data);

      transaction.set(shelterRef, {
        'status': nextStatus,
        'updated_at': FieldValue.serverTimestamp(),
        'shelter_details': {
          ...details,
          'status': nextStatus,
          'updated_at': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      _writeAuditLog(
        transaction: transaction,
        adminId: adminId,
        shelterId: shelterId,
        action: 'status_change',
        changeLog: {'status': '$currentStatus -> $nextStatus'},
        before: {'status': currentStatus},
        after: {'status': nextStatus},
      );
    });
  }

  @override
  Future<void> updateShelterCapacity({
    required String shelterId,
    required int nextCapacity,
    required String adminId,
  }) async {
    if (nextCapacity < 0) {
      throw ArgumentError('Capacity must be non-negative.');
    }

    final api = _privilegedApi;
    if (api != null) {
      await api.postJson('/v1/shelters/update-capacity', {
        'shelterId': shelterId,
        'nextCapacity': nextCapacity,
      });
      return;
    }

    final shelterRef = _firestore.collection(_sheltersCollection).doc(shelterId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(shelterRef);
      if (!snapshot.exists) throw StateError('Shelter not found: $shelterId');

      final data = snapshot.data()!;
      final details = _mapFrom(data['shelter_details']);
      final currentCapacity = _toInt(details['capacity']) ?? _toInt(data['capacity']) ?? 0;
      final currentOccupancy = _toInt(details['current_occupancy']) ??
          _toInt(data['current_occupancy']) ??
          0;

      if (nextCapacity < currentOccupancy) {
        throw StateError('Capacity cannot be lower than current occupancy.');
      }
      if (currentCapacity == nextCapacity) return;

      _assertActive(details, data);

      transaction.set(shelterRef, {
        'capacity': nextCapacity,
        'updated_at': FieldValue.serverTimestamp(),
        'shelter_details': {
          ...details,
          'capacity': nextCapacity,
          'updated_at': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      _writeAuditLog(
        transaction: transaction,
        adminId: adminId,
        shelterId: shelterId,
        action: 'capacity_update',
        changeLog: {'capacity': '$currentCapacity -> $nextCapacity'},
        before: {'capacity': currentCapacity},
        after: {'capacity': nextCapacity},
      );
    });
  }

  @override
  Future<void> updateShelterOccupancy({
    required String shelterId,
    required int nextOccupancy,
    required String adminId,
  }) async {
    if (nextOccupancy < 0) {
      throw ArgumentError('Occupancy must be non-negative.');
    }

    final api = _privilegedApi;
    if (api != null) {
      await api.postJson('/v1/shelters/update-occupancy', {
        'shelterId': shelterId,
        'nextOccupancy': nextOccupancy,
      });
      return;
    }

    final shelterRef = _firestore.collection(_sheltersCollection).doc(shelterId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(shelterRef);
      if (!snapshot.exists) throw StateError('Shelter not found: $shelterId');

      final data = snapshot.data()!;
      final details = _mapFrom(data['shelter_details']);
      final capacity = _toInt(details['capacity']) ?? _toInt(data['capacity']) ?? 0;
      final currentOccupancy = _toInt(details['current_occupancy']) ??
          _toInt(data['current_occupancy']) ??
          0;

      if (capacity > 0 && nextOccupancy > capacity) {
        throw StateError('Occupancy cannot exceed shelter capacity.');
      }
      if (currentOccupancy == nextOccupancy) return;

      _assertActive(details, data);

      transaction.set(shelterRef, {
        'current_occupancy': nextOccupancy,
        'updated_at': FieldValue.serverTimestamp(),
        'shelter_details': {
          ...details,
          'current_occupancy': nextOccupancy,
          'updated_at': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      _writeAuditLog(
        transaction: transaction,
        adminId: adminId,
        shelterId: shelterId,
        action: 'occupancy_update',
        changeLog: {'occupancy': '$currentOccupancy -> $nextOccupancy'},
        before: {'current_occupancy': currentOccupancy},
        after: {'current_occupancy': nextOccupancy},
      );
    });
  }

  @override
  Future<void> softDeleteShelter({
    required String shelterId,
    required String adminId,
  }) async {
    final api = _privilegedApi;
    if (api != null) {
      await api.postJson('/v1/shelters/soft-delete', {
        'shelterId': shelterId,
      });
      return;
    }

    final shelterRef = _firestore.collection(_sheltersCollection).doc(shelterId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(shelterRef);
      if (!snapshot.exists) throw StateError('Shelter not found: $shelterId');

      final data = snapshot.data()!;
      final details = _mapFrom(data['shelter_details']);
      final currentlyActive = (details['is_active'] == true) || (data['is_active'] == true);
      if (!currentlyActive) return;

      transaction.set(shelterRef, {
        'is_active': false,
        'status': 'Closed',
        'deleted_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'shelter_details': {
          ...details,
          'is_active': false,
          'status': 'Closed',
          'deleted_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      _writeAuditLog(
        transaction: transaction,
        adminId: adminId,
        shelterId: shelterId,
        action: 'soft_delete',
        changeLog: {'is_active': 'true -> false'},
        before: {'is_active': true},
        after: {'is_active': false},
      );
    });
  }

  void _writeAuditLog({
    required Transaction transaction,
    required String adminId,
    required String shelterId,
    required String action,
    required Map<String, dynamic> changeLog,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
  }) {
    final logRef = _firestore.collection(_logsCollection).doc();
    transaction.set(logRef, {
      'type': 'shelter_update',
      'action_type': 'shelter_update',
      'action': action,
      'admin_id': adminId,
      'target_shelter_id': shelterId,
      'target_id': shelterId,
      'change_log': changeLog,
      'before': before,
      'after': after,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _assertActive(Map<String, dynamic> details, Map<String, dynamic> root) {
    final isActive = (details['is_active'] == true) || (root['is_active'] == true);
    if (!isActive) {
      throw StateError('Cannot update soft-deleted shelter.');
    }
  }

  ShelterRecord _mapShelterDoc(String id, Map<String, dynamic> data) {
    final details = _mapFrom(data['shelter_details']);
    final location = _mapFrom(details['location'] ?? data['location']);

    final name = _trimmedString(details['name']) ??
        _trimmedString(data['name']) ??
        'Unknown Shelter';
    final status = _trimmedString(details['status']) ??
        _trimmedString(data['status']) ??
        'Closed';
    final capacity = _toInt(details['capacity']) ?? _toInt(data['capacity']) ?? 0;
    final occupancy = _toInt(details['current_occupancy']) ??
        _toInt(data['current_occupancy']) ??
        0;
    final isActive = (details['is_active'] == false || data['is_active'] == false)
        ? false
        : true;

    final zone = _trimmedString(location['zone']) ??
        _trimmedString(details['zone']) ??
        _trimmedString(data['zone']);
    final latitude = _toDouble(location['lat'] ?? location['latitude']);
    final longitude = _toDouble(location['lng'] ?? location['longitude']);
    final contact = _trimmedString(details['contact']) ?? _trimmedString(data['contact']);
    final notes = _trimmedString(details['notes']) ?? _trimmedString(data['notes']);
    final deletedAt = _toDateTime(details['deleted_at'] ?? data['deleted_at']);
    final updatedAt = _toDateTime(details['updated_at'] ?? data['updated_at']);

    return ShelterRecord(
      shelterId: id,
      name: name,
      status: status,
      capacity: capacity,
      currentOccupancy: occupancy,
      isActive: isActive,
      zone: zone,
      latitude: latitude,
      longitude: longitude,
      contact: contact,
      notes: notes,
      deletedAt: deletedAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _mapFrom(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  String? _trimmedString(dynamic value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
