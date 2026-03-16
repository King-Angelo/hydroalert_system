import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_routes.dart';
import 'core/theme/admin_theme.dart';
import 'features/auth/data/mock_auth_service.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/reports/data/mock_report_workflow_repository.dart';
import 'features/reports/data/report_workflow_repository.dart';
import 'features/shell/presentation/admin_shell_page.dart';
import 'features/system_logs/data/mock_system_logs_repository.dart';
import 'features/system_logs/data/system_logs_repository.dart';
import 'features/users/data/mock_user_management_repository.dart';
import 'features/users/data/user_management_repository.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({
    super.key,
    this.reportWorkflowRepository = const MockReportWorkflowRepository(),
    this.systemLogsRepository = const MockSystemLogsRepository(),
    this.userManagementRepository = const MockUserManagementRepository(),
    this.adminUserId = 'admin_001',
  });

  final ReportWorkflowRepository reportWorkflowRepository;
  final SystemLogsRepository systemLogsRepository;
  final UserManagementRepository userManagementRepository;
  final String adminUserId;

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
            AppRoutes.login: (_) => const LoginPage(authService: MockAuthService()),
            AppRoutes.dashboard: (_) => AdminShellPage(
              reportWorkflowRepository: reportWorkflowRepository,
              systemLogsRepository: systemLogsRepository,
              userManagementRepository: userManagementRepository,
              adminUserId: adminUserId,
            ),
          },
        );
      },
    );
  }
}