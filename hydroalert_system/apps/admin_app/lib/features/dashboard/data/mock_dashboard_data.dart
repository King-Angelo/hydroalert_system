class TelemetryMetric {
  const TelemetryMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });

  final String label;
  final String value;
  final String unit;
  final String status;
}

class ActivityLogEntry {
  const ActivityLogEntry({
    required this.message,
    required this.timeAgo,
    required this.severity,
  });

  final String message;
  final String timeAgo;
  final String severity;
}

class ActionQueueItem {
  const ActionQueueItem({
    required this.reportId,
    required this.reporter,
    required this.zone,
    required this.status,
    required this.timeAgo,
  });

  final String reportId;
  final String reporter;
  final String zone;
  final String status;
  final String timeAgo;
}

const mockTelemetryMetrics = <TelemetryMetric>[
  TelemetryMetric(label: 'Water Level', value: '2.34', unit: 'm', status: 'Critical'),
  TelemetryMetric(label: 'Flow Rate', value: '18.2', unit: 'm3/s', status: 'Elevated'),
  TelemetryMetric(label: 'Rainfall', value: '76', unit: 'mm/h', status: 'Heavy'),
];

const mockActivityFeed = <ActivityLogEntry>[
  ActivityLogEntry(
    message: 'Critical: Water level exceeded threshold at Station #12',
    timeAgo: '2m ago',
    severity: 'critical',
  ),
  ActivityLogEntry(
    message: 'Manual sensor heartbeat check completed for Node-03',
    timeAgo: '7m ago',
    severity: 'normal',
  ),
  ActivityLogEntry(
    message: 'Resident flood image submitted for Zone B',
    timeAgo: '11m ago',
    severity: 'warning',
  ),
  ActivityLogEntry(
    message: 'FCM broadcast dry-run acknowledged by 82% devices',
    timeAgo: '18m ago',
    severity: 'normal',
  ),
];

const mockActionQueue = <ActionQueueItem>[
  ActionQueueItem(
    reportId: 'RPT-0112',
    reporter: 'Resident #204',
    zone: 'Zone B Riverside',
    status: 'Pending',
    timeAgo: '3m',
  ),
  ActionQueueItem(
    reportId: 'RPT-0113',
    reporter: 'Resident #087',
    zone: 'Zone A Highway',
    status: 'Pending',
    timeAgo: '5m',
  ),
  ActionQueueItem(
    reportId: 'RPT-0114',
    reporter: 'Resident #315',
    zone: 'Zone C Lowland',
    status: 'Pending',
    timeAgo: '9m',
  ),
];