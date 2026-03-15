import 'dart:async';

import 'report_workflow_repository.dart';

class MockReportWorkflowRepository implements ReportWorkflowRepository {
  const MockReportWorkflowRepository();

  static final List<IncidentReportQueueItem> _reports = [
    IncidentReportQueueItem(
      reportId: 'report_001',
      residentId: 'resident_001',
      zone: 'Zone A',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    IncidentReportQueueItem(
      reportId: 'report_002',
      residentId: 'resident_019',
      zone: 'Zone B',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    IncidentReportQueueItem(
      reportId: 'report_003',
      residentId: 'resident_121',
      zone: 'Zone C',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
    ),
  ];

  static final StreamController<void> _updates =
      StreamController<void>.broadcast();

  @override
  Stream<List<IncidentReportQueueItem>> watchPendingReports({int limit = 20}) async* {
    yield _pending(limit);
    await for (final _ in _updates.stream) {
      yield _pending(limit);
    }
  }

  @override
  Future<void> reviewReport({
    required String reportId,
    required ReportReviewDecision decision,
    required String adminId,
    required String reviewNotes,
  }) async {
    final index = _reports.indexWhere((report) => report.reportId == reportId);
    if (index == -1) {
      throw StateError('Report not found: $reportId');
    }

    final current = _reports[index];
    if (current.status != 'Pending') {
      throw StateError('Only pending reports can be reviewed.');
    }

    final nextStatus =
        decision == ReportReviewDecision.validated ? 'Validated' : 'Rejected';
    _reports[index] = IncidentReportQueueItem(
      reportId: current.reportId,
      residentId: current.residentId,
      zone: current.zone,
      status: nextStatus,
      createdAt: current.createdAt,
    );

    _updates.add(null);
  }

  List<IncidentReportQueueItem> _pending(int limit) {
    final pending = _reports
        .where((report) => report.status == 'Pending')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return pending.take(limit).toList();
  }
}
