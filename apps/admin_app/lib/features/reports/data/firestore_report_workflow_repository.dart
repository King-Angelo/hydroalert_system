import 'package:cloud_firestore/cloud_firestore.dart';

import 'report_workflow_repository.dart';

class FirestoreReportWorkflowRepository implements ReportWorkflowRepository {
  FirestoreReportWorkflowRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _reportsCollection = 'Incident_Reports';
  static const _logsCollection = 'System_Logs';

  @override
  Stream<List<IncidentReportQueueItem>> watchPendingReports({int limit = 20}) {
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

  IncidentReportQueueItem _mapReportDoc(String id, Map<String, dynamic> data) {
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

    return IncidentReportQueueItem(
      reportId: id,
      residentId: residentId,
      zone: zone,
      status: status,
      createdAt: createdAt,
    );
  }
}
