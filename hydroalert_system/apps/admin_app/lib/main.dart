import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'app.dart';
import 'core/config/admin_api_config.dart';
import 'core/config/runtime_environment.dart';
import 'core/observability/firebase_observability.dart';
import 'features/alerts/data/manual_override_api_client.dart';
import 'firebase_options.dart';
import 'features/auth/data/auth_service_factory.dart';
import 'features/reports/data/report_workflow_repository_factory.dart';
import 'features/shelters/data/shelter_logistics_repository_factory.dart';
import 'features/system_logs/data/system_logs_repository_factory.dart';
import 'features/users/data/user_management_repository_factory.dart';
import 'features/iot_devices/data/iot_devices_repository_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    debugPrint(
      'HydroAlert admin: HYDRO_ENV=${RuntimeEnvironment.label} '
      '(set via --dart-define=HYDRO_ENV=dev|staging|production)',
    );
  }
  var firebaseReady = false;
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await setupFirebaseObservability();
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
  final authService = AuthServiceFactory.create(
    firebaseReady: firebaseReady,
  );
  final iotDevicesRepository = IotDevicesRepositoryFactory.create(
    firebaseReady: firebaseReady,
  );

  ManualOverrideApiClient? manualOverrideClient;
  if (firebaseReady && AdminApiConfig.isConfigured) {
    manualOverrideClient = ManualOverrideApiClient(
      baseUrl: AdminApiConfig.baseUrl,
      getIdToken: authService.getIdToken,
    );
  }

  runApp(
    AdminApp(
      reportWorkflowRepository: reportWorkflowRepository,
      shelterLogisticsRepository: shelterLogisticsRepository,
      systemLogsRepository: systemLogsRepository,
      userManagementRepository: userManagementRepository,
      iotDevicesRepository: iotDevicesRepository,
      authService: authService,
      manualOverrideApiClient: manualOverrideClient,
    ),
  );
}
