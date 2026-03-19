class ShelterRecord {
  const ShelterRecord({
    required this.shelterId,
    required this.name,
    required this.status,
    required this.capacity,
    required this.currentOccupancy,
    required this.isActive,
    this.zone,
    this.latitude,
    this.longitude,
    this.contact,
    this.notes,
    this.deletedAt,
    this.updatedAt,
  });

  final String shelterId;
  final String name;
  final String status; // Open | Closed
  final int capacity;
  final int currentOccupancy;
  final bool isActive;
  final String? zone;
  final double? latitude;
  final double? longitude;
  final String? contact;
  final String? notes;
  final DateTime? deletedAt;
  final DateTime? updatedAt;

  double get occupancyRatio => capacity <= 0 ? 0 : currentOccupancy / capacity;
}

enum ShelterOccupancyFilter {
  all,
  available,
  nearCapacity,
  full,
}

abstract class ShelterLogisticsRepository {
  Stream<List<ShelterRecord>> watchShelters();

  Future<void> updateShelterStatus({
    required String shelterId,
    required String nextStatus,
    required String adminId,
  });

  Future<void> updateShelterCapacity({
    required String shelterId,
    required int nextCapacity,
    required String adminId,
  });

  Future<void> updateShelterOccupancy({
    required String shelterId,
    required int nextOccupancy,
    required String adminId,
  });

  Future<void> softDeleteShelter({
    required String shelterId,
    required String adminId,
  });
}
