import 'dart:async';

import 'shelter_logistics_repository.dart';

class MockShelterLogisticsRepository implements ShelterLogisticsRepository {
  const MockShelterLogisticsRepository();

  static final List<ShelterRecord> _shelters = [
    ShelterRecord(
      shelterId: 'shelter_001',
      name: 'Barangay Hall Gym',
      status: 'Open',
      capacity: 250,
      currentOccupancy: 164,
      isActive: true,
      zone: 'Central',
      latitude: 14.5995,
      longitude: 120.9842,
      contact: '0917-111-0001',
      notes: 'Main relief distribution hub.',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 9)),
    ),
    ShelterRecord(
      shelterId: 'shelter_002',
      name: 'North Covered Court',
      status: 'Open',
      capacity: 120,
      currentOccupancy: 118,
      isActive: true,
      zone: 'North',
      latitude: 14.6028,
      longitude: 120.9821,
      contact: '0917-111-0002',
      notes: 'Near-capacity location for northern residents.',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 14)),
    ),
    ShelterRecord(
      shelterId: 'shelter_003',
      name: 'South Elementary School',
      status: 'Closed',
      capacity: 180,
      currentOccupancy: 0,
      isActive: true,
      zone: 'Southern',
      latitude: 14.5959,
      longitude: 120.9864,
      contact: '0917-111-0003',
      notes: 'Closed due to facility maintenance.',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  static final StreamController<void> _updates =
      StreamController<void>.broadcast();

  @override
  Stream<List<ShelterRecord>> watchShelters() async* {
    yield _snapshot();
    await for (final _ in _updates.stream) {
      yield _snapshot();
    }
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
    final index = _indexOf(shelterId);
    final current = _shelters[index];
    if (!current.isActive) throw StateError('Cannot update soft-deleted shelter.');
    _shelters[index] = ShelterRecord(
      shelterId: current.shelterId,
      name: current.name,
      status: nextStatus,
      capacity: current.capacity,
      currentOccupancy: current.currentOccupancy,
      isActive: current.isActive,
      zone: current.zone,
      latitude: current.latitude,
      longitude: current.longitude,
      contact: current.contact,
      notes: current.notes,
      deletedAt: current.deletedAt,
      updatedAt: DateTime.now(),
    );
    _updates.add(null);
  }

  @override
  Future<void> updateShelterCapacity({
    required String shelterId,
    required int nextCapacity,
    required String adminId,
  }) async {
    if (nextCapacity < 0) throw ArgumentError('Capacity must be non-negative.');
    final index = _indexOf(shelterId);
    final current = _shelters[index];
    if (!current.isActive) throw StateError('Cannot update soft-deleted shelter.');
    if (nextCapacity < current.currentOccupancy) {
      throw StateError('Capacity cannot be lower than current occupancy.');
    }
    _shelters[index] = ShelterRecord(
      shelterId: current.shelterId,
      name: current.name,
      status: current.status,
      capacity: nextCapacity,
      currentOccupancy: current.currentOccupancy,
      isActive: current.isActive,
      zone: current.zone,
      latitude: current.latitude,
      longitude: current.longitude,
      contact: current.contact,
      notes: current.notes,
      deletedAt: current.deletedAt,
      updatedAt: DateTime.now(),
    );
    _updates.add(null);
  }

  @override
  Future<void> updateShelterOccupancy({
    required String shelterId,
    required int nextOccupancy,
    required String adminId,
  }) async {
    if (nextOccupancy < 0) throw ArgumentError('Occupancy must be non-negative.');
    final index = _indexOf(shelterId);
    final current = _shelters[index];
    if (!current.isActive) throw StateError('Cannot update soft-deleted shelter.');
    if (nextOccupancy > current.capacity) {
      throw StateError('Occupancy cannot exceed shelter capacity.');
    }
    _shelters[index] = ShelterRecord(
      shelterId: current.shelterId,
      name: current.name,
      status: current.status,
      capacity: current.capacity,
      currentOccupancy: nextOccupancy,
      isActive: current.isActive,
      zone: current.zone,
      latitude: current.latitude,
      longitude: current.longitude,
      contact: current.contact,
      notes: current.notes,
      deletedAt: current.deletedAt,
      updatedAt: DateTime.now(),
    );
    _updates.add(null);
  }

  @override
  Future<void> softDeleteShelter({
    required String shelterId,
    required String adminId,
  }) async {
    final index = _indexOf(shelterId);
    final current = _shelters[index];
    if (!current.isActive) return;
    _shelters[index] = ShelterRecord(
      shelterId: current.shelterId,
      name: current.name,
      status: 'Closed',
      capacity: current.capacity,
      currentOccupancy: current.currentOccupancy,
      isActive: false,
      zone: current.zone,
      latitude: current.latitude,
      longitude: current.longitude,
      contact: current.contact,
      notes: current.notes,
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _updates.add(null);
  }

  int _indexOf(String shelterId) {
    final index = _shelters.indexWhere((shelter) => shelter.shelterId == shelterId);
    if (index == -1) throw StateError('Shelter not found: $shelterId');
    return index;
  }

  List<ShelterRecord> _snapshot() {
    final list = _shelters.toList()
      ..sort((a, b) {
        final byZone = (a.zone ?? '').compareTo(b.zone ?? '');
        if (byZone != 0) return byZone;
        return a.name.compareTo(b.name);
      });
    return list;
  }
}
