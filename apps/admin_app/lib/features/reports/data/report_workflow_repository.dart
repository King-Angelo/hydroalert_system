class IncidentReportQueueItem {
  const IncidentReportQueueItem({
    required this.reportId,
    required this.residentId,
    required this.zone,
    required this.status,
    required this.createdAt,
  });

  final String reportId;
  final String residentId;
  final String zone;
  final String status;
  final DateTime createdAt;
}

enum ReportReviewDecision {
  validated,
  rejected,
}

abstract class ReportWorkflowRepository {
  Stream<List<IncidentReportQueueItem>> watchPendingReports({int limit = 20});

  Future<void> reviewReport({
    required String reportId,
    required ReportReviewDecision decision,
    required String adminId,
    required String reviewNotes,
  });
}
