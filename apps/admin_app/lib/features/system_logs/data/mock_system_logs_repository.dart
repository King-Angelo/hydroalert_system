import 'dart:async';

import 'system_logs_repository.dart';

class MockSystemLogsRepository implements SystemLogsRepository {
  const MockSystemLogsRepository();

  static final List<SystemLogRecord> _logs = [
    SystemLogRecord(
      logId: 'log_001',
      type: 'report_review',
      action: 'Validated',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      adminId: 'admin_001',
      targetId: 'report_004',
      targetReportId: 'report_004',
      notes: 'Confirmed by matching photo and telemetry trend.',
      before: const {'status': 'Pending'},
      after: const {'status': 'Validated'},
      raw: const {'source': 'mock'},
    ),
    SystemLogRecord(
      logId: 'log_002',
      type: 'user_management_action',
      action: 'deactivate_user',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      adminId: 'admin_001',
      targetId: 'resident_099',
      targetUserId: 'resident_099',
      notes: 'Temporary deactivation due to suspicious token behavior.',
      before: const {'is_active': true},
      after: const {'is_active': false},
      raw: const {'source': 'mock'},
    ),
    SystemLogRecord(
      logId: 'log_003',
      type: 'sensor_maintenance',
      action: 'threshold_update',
      timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      adminId: 'admin_001',
      targetId: 'sensor_012',
      targetSensorId: 'sensor_012',
      notes: 'Adjusted warning threshold due to recent rainfall trend.',
      before: const {'warning_level_cm': 85},
      after: const {'warning_level_cm': 78},
      raw: const {'source': 'mock'},
    ),
  ];

  static final StreamController<void> _updates =
      StreamController<void>.broadcast();

  @override
  Stream<List<SystemLogRecord>> watchRecentLogs({int limit = 100}) async* {
    yield _recent(limit);
    await for (final _ in _updates.stream) {
      yield _recent(limit);
    }
  }

  @override
  Future<SystemLogsPageResult> fetchLogsPage({
    int pageSize = 100,
    DateTime? startAfterTimestamp,
  }) async {
    final sorted = _logs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final pageSource = startAfterTimestamp == null
        ? sorted
        : sorted.where((log) => log.timestamp.isBefore(startAfterTimestamp)).toList();

    final hasNext = pageSource.length > pageSize;
    final visible = pageSource.take(pageSize).toList();
    final nextCursor = hasNext && visible.isNotEmpty ? visible.last.timestamp : null;

    return SystemLogsPageResult(
      items: visible,
      hasNextPage: hasNext,
      nextCursorTimestamp: nextCursor,
    );
  }

  List<SystemLogRecord> _recent(int limit) {
    final sorted = _logs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }
}
