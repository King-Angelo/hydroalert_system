import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_routes.dart';
import 'core/theme/admin_theme.dart';
import 'features/auth/data/mock_auth_service.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/shell/presentation/admin_shell_page.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

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
            AppRoutes.dashboard: (_) => const AdminShellPage(),
          },
        );
      },
    );
  }
}