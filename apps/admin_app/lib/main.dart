import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'features/reports/data/report_workflow_repository_factory.dart';
import 'features/shelters/data/shelter_logistics_repository_factory.dart';
import 'features/system_logs/data/system_logs_repository_factory.dart';
import 'features/users/data/user_management_repository_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;
    }
  } catch (error, stackTrace) {
    debugPrint('Firebase init failed; using mock report workflow repository.');
    debugPrint('$error');
    debugPrint('$stackTrace');
  }

  final reportWorkflowRepository = ReportWorkflowRepositoryFactory.create(
    firebaseReady: firebaseReady,
  );
  final userManagementRepository = UserManagementRepositoryFactory.create(
    firebaseReady: firebaseReady,
  );
  final systemLogsRepository = SystemLogsRepositoryFactory.create(
    firebaseReady: firebaseReady,
  );
  final shelterLogisticsRepository = ShelterLogisticsRepositoryFactory.create(
    firebaseReady: firebaseReady,
  );
  runApp(
    AdminApp(
      reportWorkflowRepository: reportWorkflowRepository,
      shelterLogisticsRepository: shelterLogisticsRepository,
      systemLogsRepository: systemLogsRepository,
      userManagementRepository: userManagementRepository,
    ),
  );
}
