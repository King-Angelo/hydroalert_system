import 'package:cloud_firestore/cloud_firestore.dart';

import 'report_workflow_repository.dart';

class FirestoreReportWorkflowRepository implements ReportWorkflowRepository {
  FirestoreReportWorkflowRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _reportsCollection = 'Incident_Reports';
  static const _logsCollection = 'System_Logs';

  @override
  Stream<List<IncidentReportRecord>> watchPendingReports({int limit = 20}) {
    return _firestore
        .collection(_reportsCollection)
        .where('status', isEqualTo: 'Pending')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _mapReportDoc(doc.id, doc.data()))
              .toList();
        });
  }

  @override
  Future<IncidentReportPageResult> fetchReportsPage({
    required String statusFilter,
    int pageSize = 20,
    DateTime? startAfterCreatedAt,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_reportsCollection)
        .orderBy('created_at', descending: true);

    if (statusFilter != 'All') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    if (startAfterCreatedAt != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterCreatedAt)]);
    }

    final snapshot = await query.limit(pageSize + 1).get();
    final hasNext = snapshot.docs.length > pageSize;
    final visibleDocs = hasNext
        ? snapshot.docs.take(pageSize).toList()
        : snapshot.docs;

    final items = visibleDocs
        .map((doc) => _mapReportDoc(doc.id, doc.data()))
        .toList();

    final nextCursor = hasNext && items.isNotEmpty ? items.last.createdAt : null;
    return IncidentReportPageResult(
      items: items,
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
    final reportRef = _firestore.collection(_reportsCollection).doc(reportId);
    final logRef = _firestore.collection(_logsCollection).doc();

    await _firestore.runTransaction((transaction) async {
      final reportSnapshot = await transaction.get(reportRef);
      if (!reportSnapshot.exists) {
        throw StateError('Report not found: $reportId');
      }

      final data = reportSnapshot.data()!;
      final currentStatus = (data['status'] as String?) ?? '';
      if (currentStatus != 'Pending') {
        throw StateError('Only pending reports can be reviewed.');
      }

      final nextStatus =
          decision == ReportReviewDecision.validated ? 'Validated' : 'Rejected';
      final trimmedNotes = reviewNotes.trim();

      transaction.update(reportRef, {
        'status': nextStatus,
        'reviewed_by': adminId,
        'reviewed_at': FieldValue.serverTimestamp(),
        'review_notes': trimmedNotes,
      });

      transaction.set(logRef, {
        'type': 'report_review',
        'admin_id': adminId,
        'target_report_id': reportId,
        'action': nextStatus,
        'before_status': currentStatus,
        'after_status': nextStatus,
        'notes': trimmedNotes,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  IncidentReportRecord _mapReportDoc(String id, Map<String, dynamic> data) {
    final location = data['location'];
    final locationMap = location is Map<String, dynamic> ? location : null;
    final zoneRaw = locationMap?['zone'];
    final zone = zoneRaw is String && zoneRaw.trim().isNotEmpty
        ? zoneRaw.trim()
        : 'Unknown Zone';

    final residentRaw = data['resident_id'];
    final residentId = residentRaw is String && residentRaw.trim().isNotEmpty
        ? residentRaw.trim()
        : 'unknown_resident';

    final statusRaw = data['status'];
    final status = statusRaw is String && statusRaw.trim().isNotEmpty
        ? statusRaw.trim()
        : 'Pending';

    final createdAtRaw = data['created_at'];
    DateTime createdAt = DateTime.now();
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    }

    final description = _trimmedString(data['description']);
    final photoUrl = _trimmedString(data['photo_url']);
    final reviewedBy = _trimmedString(data['reviewed_by']);
    final reviewNotes = _trimmedString(data['review_notes']);
    final reviewedAtRaw = data['reviewed_at'];
    DateTime? reviewedAt;
    if (reviewedAtRaw is Timestamp) {
      reviewedAt = reviewedAtRaw.toDate();
    } else if (reviewedAtRaw is DateTime) {
      reviewedAt = reviewedAtRaw;
    }

    final latitude = _toDouble(locationMap?['lat']);
    final longitude = _toDouble(locationMap?['lng']);

    return IncidentReportRecord(
      reportId: id,
      residentId: residentId,
      zone: zone,
      status: status,
      createdAt: createdAt,
      description: description,
      photoUrl: photoUrl,
      latitude: latitude,
      longitude: longitude,
      reviewedBy: reviewedBy,
      reviewedAt: reviewedAt,
      reviewNotes: reviewNotes,
    );
  }

  String? _trimmedString(dynamic value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
