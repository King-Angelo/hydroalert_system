import '../../system_logs/data/system_logs_repository.dart';
import 'mock_dashboard_data.dart';

/// Maps [SystemLogRecord] rows to dashboard [ActivityLogEntry].
List<ActivityLogEntry> activityEntriesFromSystemLogs(List<SystemLogRecord> logs) {
  return logs.map(activityEntryFromSystemLog).toList();
}

ActivityLogEntry activityEntryFromSystemLog(SystemLogRecord log) {
  return ActivityLogEntry(
    message: _messageFor(log),
    timeAgo: _formatTimeAgo(log.timestamp),
    severity: _severityFor(log),
  );
}

String _messageFor(SystemLogRecord log) {
  final raw = log.raw;
  final explicit = _trim(raw?['message'] as String?);
  if (explicit != null && explicit.isNotEmpty) {
    return explicit;
  }

  final target = log.targetReportId ?? log.targetUserId ?? log.targetSensorId ?? log.targetId;
  final buf = StringBuffer('${log.type} · ${log.action}');
  if (target != null && target.isNotEmpty) {
    buf.write(' ($target)');
  }
  final notes = log.notes;
  if (notes != null && notes.isNotEmpty) {
    final short = notes.length > 120 ? '${notes.substring(0, 117)}…' : notes;
    buf.write(' — $short');
  }
  return buf.toString();
}

String _severityFor(SystemLogRecord log) {
  final s = _trim(log.raw?['severity'] as String?)?.toLowerCase() ?? '';
  if (s == 'warning') return 'critical';
  if (s == 'watch' || s == 'advisory') return 'warning';
  if (s == 'normal') return 'normal';

  final action = log.action.toLowerCase();
  if (action.contains('reject') ||
      action.contains('deactivate') ||
      action.contains('delete')) {
    return 'warning';
  }

  final type = log.type.toLowerCase();
  if (type.contains('error') || type.contains('fail')) return 'critical';

  return 'normal';
}

String? _trim(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

String _formatTimeAgo(DateTime timestamp) {
  final d = DateTime.now().difference(timestamp);
  if (d.isNegative) return 'just now';
  if (d.inSeconds < 45) return '${d.inSeconds}s ago';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
}
