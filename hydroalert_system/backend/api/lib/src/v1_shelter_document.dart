import 'v1_firestore_writes.dart';

/// Reads shelter fields the same way as [FirestoreShelterLogisticsRepository] in admin_app
/// (root vs nested `shelter_details`).
Map<String, dynamic> v1ShelterDetailsMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }
  return <String, dynamic>{};
}

bool v1ShelterIsActive(Map<String, dynamic> data) {
  final details = v1ShelterDetailsMap(data['shelter_details']);
  final fromDetails = details['is_active'];
  final fromRoot = data['is_active'];
  if (fromDetails == false || fromRoot == false) return false;
  return true;
}

String? v1ShelterTrimmedString(dynamic value) {
  if (value is! String) return null;
  final t = value.trim();
  return t.isEmpty ? null : t;
}

String v1ShelterStatus(Map<String, dynamic> data) {
  final details = v1ShelterDetailsMap(data['shelter_details']);
  return v1ShelterTrimmedString(details['status']) ??
      v1ShelterTrimmedString(data['status']) ??
      'Closed';
}

int v1ShelterCapacity(Map<String, dynamic> data) {
  final details = v1ShelterDetailsMap(data['shelter_details']);
  return readFirestoreInt(details['capacity']) ??
      readFirestoreInt(data['capacity']) ??
      0;
}

int v1ShelterOccupancy(Map<String, dynamic> data) {
  final details = v1ShelterDetailsMap(data['shelter_details']);
  return readFirestoreInt(details['current_occupancy']) ??
      readFirestoreInt(data['current_occupancy']) ??
      0;
}
