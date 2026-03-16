class SystemLogRecord {
  const SystemLogRecord({
    required this.logId,
    required this.type,
    required this.action,
    required this.timestamp,
    this.adminId,
    this.targetId,
    this.targetReportId,
    this.targetUserId,
    this.targetSensorId,
    this.notes,
    this.before,
    this.after,
    this.raw,
  });

  final String logId;
  final String type;
  final String action;
  final DateTime timestamp;
  final String? adminId;
  final String? targetId;
  final String? targetReportId;
  final String? targetUserId;
  final String? targetSensorId;
  final String? notes;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final Map<String, dynamic>? raw;
}

class SystemLogsPageResult {
  const SystemLogsPageResult({
    required this.items,
    required this.hasNextPage,
    required this.nextCursorTimestamp,
  });

  final List<SystemLogRecord> items;
  final bool hasNextPage;
  final DateTime? nextCursorTimestamp;
}

abstract class SystemLogsRepository {
  Stream<List<SystemLogRecord>> watchRecentLogs({int limit = 100});

  Future<SystemLogsPageResult> fetchLogsPage({
    int pageSize = 100,
    DateTime? startAfterTimestamp,
  });
}
