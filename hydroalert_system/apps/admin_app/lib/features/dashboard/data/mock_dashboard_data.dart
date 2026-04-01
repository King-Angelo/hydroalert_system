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