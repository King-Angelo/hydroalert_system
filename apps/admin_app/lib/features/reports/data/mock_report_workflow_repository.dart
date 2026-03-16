import 'dart:async';

import 'report_workflow_repository.dart';

class MockReportWorkflowRepository implements ReportWorkflowRepository {
  const MockReportWorkflowRepository();

  static final List<IncidentReportRecord> _reports = [
    IncidentReportRecord(
      reportId: 'report_001',
      residentId: 'resident_001',
      zone: 'Zone A',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      description: 'Flooded road near bridge.',
      photoUrl: 'https://example.com/flood-photo-001.jpg',
      latitude: 14.602,
      longitude: 120.986,
    ),
    IncidentReportRecord(
      reportId: 'report_002',
      residentId: 'resident_019',
      zone: 'Zone B',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      description: 'Rapid increase in water near riverside homes.',
      photoUrl: 'https://example.com/flood-photo-002.jpg',
      latitude: 14.603,
      longitude: 120.987,
    ),
    IncidentReportRecord(
      reportId: 'report_003',
      residentId: 'resident_121',
      zone: 'Zone C',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
      description: 'Drainage overflow observed on main road.',
      photoUrl: 'https://example.com/flood-photo-003.jpg',
      latitude: 14.604,
      longitude: 120.988,
    ),
    IncidentReportRecord(
      reportId: 'report_004',
      residentId: 'resident_210',
      zone: 'Zone A',
      status: 'Validated',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 7)),
      description: 'Flood signs near elementary school.',
      photoUrl: 'https://example.com/flood-photo-004.jpg',
      latitude: 14.601,
      longitude: 120.984,
      reviewedBy: 'admin_001',
      reviewedAt: DateTime.now().subtract(const Duration(hours: 1)),
      reviewNotes: 'Confirmed by photo and sensor trend.',
    ),
    IncidentReportRecord(
      reportId: 'report_005',
      residentId: 'resident_333',
      zone: 'Zone D',
      status: 'Rejected',
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      description: 'Report with unclear evidence.',
      photoUrl: 'https://example.com/flood-photo-005.jpg',
      latitude: 14.605,
      longitude: 120.99,
      reviewedBy: 'admin_001',
      reviewedAt: DateTime.now().subtract(const Duration(hours: 2)),
      reviewNotes: 'Image was unrelated to flood conditions.',
    ),
  ];

  static final StreamController<void> _updates =
      StreamController<void>.broadcast();

  @override
  Stream<List<IncidentReportRecord>> watchPendingReports({int limit = 20}) async* {
    yield _pending(limit);
    await for (final _ in _updates.stream) {
      yield _pending(limit);
    }
  }

  @override
  Future<IncidentReportPageResult> fetchReportsPage({
    required String statusFilter,
    int pageSize = 20,
    DateTime? startAfterCreatedAt,
  }) async {
    final filtered = _reports
        .where((report) =>
            statusFilter == 'All' || report.status == statusFilter)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final pageItems = startAfterCreatedAt == null
        ? filtered
        : filtered
            .where((report) => report.createdAt.isBefore(startAfterCreatedAt))
            .toList();

    final hasNext = pageItems.length > pageSize;
    final visible = pageItems.take(pageSize).toList();
    final nextCursor = hasNext && visible.isNotEmpty ? visible.last.createdAt : null;

    return IncidentReportPageResult(
      items: visible,
      hasNextPage: hasNext,
      nextCursorCreatedAt: nextCursor,
    );
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
    _reports[index] = IncidentReportRecord(
      reportId: current.reportId,
      residentId: current.residentId,
      zone: current.zone,
      status: nextStatus,
      createdAt: current.createdAt,
      description: current.description,
      photoUrl: current.photoUrl,
      latitude: current.latitude,
      longitude: current.longitude,
      reviewedBy: adminId,
      reviewedAt: DateTime.now(),
      reviewNotes: reviewNotes.trim().isEmpty ? null : reviewNotes.trim(),
    );

    _updates.add(null);
  }

  List<IncidentReportRecord> _pending(int limit) {
    final pending = _reports
        .where((report) => report.status == 'Pending')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return pending.take(limit).toList();
  }
}
