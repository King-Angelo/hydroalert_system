class IncidentReportRecord {
  const IncidentReportRecord({
    required this.reportId,
    required this.residentId,
    required this.zone,
    required this.status,
    required this.createdAt,
    this.description,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  final String reportId;
  final String residentId;
  final String zone;
  final String status;
  final DateTime createdAt;
  final String? description;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
}

class IncidentReportPageResult {
  const IncidentReportPageResult({
    required this.items,
    required this.hasNextPage,
    required this.nextCursorCreatedAt,
  });

  final List<IncidentReportRecord> items;
  final bool hasNextPage;
  final DateTime? nextCursorCreatedAt;
}

enum ReportReviewDecision {
  validated,
  rejected,
}

abstract class ReportWorkflowRepository {
  Stream<List<IncidentReportRecord>> watchPendingReports({int limit = 20});

  Future<IncidentReportPageResult> fetchReportsPage({
    required String statusFilter,
    int pageSize = 20,
    DateTime? startAfterCreatedAt,
  });

  Future<void> reviewReport({
    required String reportId,
    required ReportReviewDecision decision,
    required String adminId,
    required String reviewNotes,
  });
}
