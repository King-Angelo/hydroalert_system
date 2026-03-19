import 'package:cloud_firestore/cloud_firestore.dart';

import 'system_logs_repository.dart';

class FirestoreSystemLogsRepository implements SystemLogsRepository {
  FirestoreSystemLogsRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _logsCollection = 'System_Logs';

  @override
  Stream<List<SystemLogRecord>> watchRecentLogs({int limit = 100}) {
    return _firestore
        .collection(_logsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _mapLogDoc(doc.id, doc.data()))
              .toList();
        });
  }

  @override
  Future<SystemLogsPageResult> fetchLogsPage({
    int pageSize = 100,
    DateTime? startAfterTimestamp,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_logsCollection)
        .orderBy('timestamp', descending: true);

    if (startAfterTimestamp != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterTimestamp)]);
    }

    final snapshot = await query.limit(pageSize + 1).get();
    final hasNext = snapshot.docs.length > pageSize;
    final visibleDocs = hasNext
        ? snapshot.docs.take(pageSize).toList()
        : snapshot.docs;
    final items = visibleDocs
        .map((doc) => _mapLogDoc(doc.id, doc.data()))
        .toList();

    final nextCursor = hasNext && items.isNotEmpty ? items.last.timestamp : null;
    return SystemLogsPageResult(
      items: items,
      hasNextPage: hasNext,
      nextCursorTimestamp: nextCursor,
    );
  }

  SystemLogRecord _mapLogDoc(String id, Map<String, dynamic> data) {
    final timestampValue = data['timestamp'];
    DateTime timestamp = DateTime.now();
    if (timestampValue is Timestamp) {
      timestamp = timestampValue.toDate();
    } else if (timestampValue is DateTime) {
      timestamp = timestampValue;
    }

    final type = _trimmedString(data['type']) ?? 'unknown';
    final action = _trimmedString(data['action']) ?? 'unknown';
    final adminId = _trimmedString(data['admin_id']);
    final targetReportId = _trimmedString(data['target_report_id']);
    final targetUserId = _trimmedString(data['target_user_id']);
    final targetSensorId =
        _trimmedString(data['target_sensor_id']) ?? _trimmedString(data['sensor_id']);
    final notes = _trimmedString(data['notes']);
    final before = _toStringKeyMap(data['before']);
    final after = _toStringKeyMap(data['after']);

    final targetId =
        targetReportId ??
        targetUserId ??
        targetSensorId ??
        _trimmedString(data['target_alert_id']) ??
        _trimmedString(data['target_id']);

    return SystemLogRecord(
      logId: id,
      type: type,
      action: action,
      timestamp: timestamp,
      adminId: adminId,
      targetId: targetId,
      targetReportId: targetReportId,
      targetUserId: targetUserId,
      targetSensorId: targetSensorId,
      notes: notes,
      before: before,
      after: after,
      raw: data,
    );
  }

  String? _trimmedString(dynamic value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  Map<String, dynamic>? _toStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    }
    return null;
  }
}
