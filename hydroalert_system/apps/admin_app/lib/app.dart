import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_routes.dart';
import 'core/theme/admin_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/data/mock_auth_service.dart';
import 'features/auth/presentation/admin_auth_gate_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/reports/data/mock_report_workflow_repository.dart';
import 'features/reports/data/report_workflow_repository.dart';
import 'features/shelters/data/mock_shelter_logistics_repository.dart';
import 'features/shelters/data/shelter_logistics_repository.dart';
import 'features/shell/presentation/admin_shell_page.dart';
import 'features/system_logs/data/mock_system_logs_repository.dart';
import 'features/system_logs/data/system_logs_repository.dart';
import 'features/users/data/mock_user_management_repository.dart';
import 'features/users/data/user_management_repository.dart';
import 'features/alerts/data/manual_override_api_client.dart';
import 'features/iot_devices/data/iot_devices_repository.dart';
import 'features/iot_devices/data/mock_iot_devices_repository.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({
    super.key,
    this.reportWorkflowRepository = const MockReportWorkflowRepository(),
    this.shelterLogisticsRepository = const MockShelterLogisticsRepository(),
    this.systemLogsRepository = const MockSystemLogsRepository(),
    this.userManagementRepository = const MockUserManagementRepository(),
    this.iotDevicesRepository = const MockIotDevicesRepository(),
    this.authService = const MockAuthService(),
    this.manualOverrideApiClient,
  });

  final ReportWorkflowRepository reportWorkflowRepository;
  final ShelterLogisticsRepository shelterLogisticsRepository;
  final SystemLogsRepository systemLogsRepository;
  final UserManagementRepository userManagementRepository;
  final IotDevicesRepository iotDevicesRepository;
  final AuthService authService;
  final ManualOverrideApiClient? manualOverrideApiClient;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.locale,
      builder: (context, locale, child) {
        return MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildAdminDarkTheme(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppRoutes.login,
          routes: {
            AppRoutes.login: (_) => LoginPage(authService: authService),
            AppRoutes.dashboard: (_) => AdminAuthGatePage(
              authService: authService,
              builder: (context, adminUserId) => AdminShellPage(
                reportWorkflowRepository: reportWorkflowRepository,
                shelterLogisticsRepository: shelterLogisticsRepository,
                systemLogsRepository: systemLogsRepository,
                userManagementRepository: userManagementRepository,
                iotDevicesRepository: iotDevicesRepository,
                authService: authService,
                adminUserId: adminUserId,
                manualOverrideApiClient: manualOverrideApiClient,
              ),
            ),
          },
        );
      },
    );
  }
}