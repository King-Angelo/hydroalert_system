import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'features/reports/data/report_workflow_repository_factory.dart';

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
  runApp(AdminApp(reportWorkflowRepository: reportWorkflowRepository));
}
