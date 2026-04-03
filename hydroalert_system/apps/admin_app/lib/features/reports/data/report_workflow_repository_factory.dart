import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/api/admin_authenticated_http_client.dart';
import 'firestore_report_workflow_repository.dart';
import 'mock_report_workflow_repository.dart';
import 'report_workflow_repository.dart';

class ReportWorkflowRepositoryFactory {
  static ReportWorkflowRepository create({
    required bool firebaseReady,
    AdminAuthenticatedHttpClient? privilegedApi,
  }) {
    if (firebaseReady && Firebase.apps.isNotEmpty) {
      return FirestoreReportWorkflowRepository(
        firestore: FirebaseFirestore.instance,
        privilegedApi: privilegedApi,
      );
    }

    return const MockReportWorkflowRepository();
  }
}
