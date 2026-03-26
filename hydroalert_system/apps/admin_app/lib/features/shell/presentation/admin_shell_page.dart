import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/locale_controller.dart';
import '../../auth/data/auth_service.dart';
import '../../reports/data/report_workflow_repository.dart';
import '../../reports/presentation/reports_page.dart';
import '../../shelters/data/shelter_logistics_repository.dart';
import '../../shelters/presentation/shelter_logistics_page.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../system_logs/data/system_logs_repository.dart';
import '../../system_logs/presentation/system_logs_page.dart';
import '../../users/data/user_management_repository.dart';
import '../../users/presentation/user_management_page.dart';
import '../../alerts/data/manual_override_api_client.dart';
import '../../iot_devices/data/iot_devices_repository.dart';
import '../../iot_devices/presentation/iot_devices_page.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({
    super.key,
    required this.reportWorkflowRepository,
    required this.shelterLogisticsRepository,
    required this.systemLogsRepository,
    required this.userManagementRepository,
    required this.iotDevicesRepository,
    required this.authService,
    required this.adminUserId,
    this.manualOverrideApiClient,
  });

  final ReportWorkflowRepository reportWorkflowRepository;
  final ShelterLogisticsRepository shelterLogisticsRepository;
  final SystemLogsRepository systemLogsRepository;
  final UserManagementRepository userManagementRepository;
  final IotDevicesRepository iotDevicesRepository;
  final AuthService authService;
  final String adminUserId;
  final ManualOverrideApiClient? manualOverrideApiClient;

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _selectedIndex = 0;
  StreamSubscription<void>? _sessionSub;

  static const _sections = <_NavSection>[
    _NavSection.dashboard,
    _NavSection.incidentVerification,
    _NavSection.userManagement,
    _NavSection.systemLogs,
    _NavSection.shelterLogistics,
    _NavSection.iotDevices,
  ];

  IconData _iconForSection(_NavSection section) {
    switch (section) {
      case _NavSection.dashboard:
        return Icons.space_dashboard_rounded;
      case _NavSection.incidentVerification:
        return Icons.fact_check_outlined;
      case _NavSection.userManagement:
        return Icons.people_alt_outlined;
      case _NavSection.systemLogs:
        return Icons.receipt_long_outlined;
      case _NavSection.shelterLogistics:
        return Icons.home_work_outlined;
      case _NavSection.iotDevices:
        return Icons.sensors_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _sessionSub = widget.authService.sessionTerminated.listen((_) {
      if (!mounted) return;
      final message = context.l10n.sessionTerminatedMessage;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
        arguments: message,
      );
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  String _labelForSection(BuildContext context, _NavSection section) {
    final l10n = context.l10n;
    switch (section) {
      case _NavSection.dashboard:
        return l10n.navDashboard;
      case _NavSection.incidentVerification:
        return l10n.navIncidentVerification;
      case _NavSection.userManagement:
        return l10n.navUserManagement;
      case _NavSection.systemLogs:
        return l10n.navSystemLogs;
      case _NavSection.shelterLogistics:
        return l10n.navShelterLogistics;
      case _NavSection.iotDevices:
        return l10n.navIoTDevices;
    }
  }

  Widget _buildCurrentPage(BuildContext context) {
    final section = _sections[_selectedIndex];

    switch (section) {
      case _NavSection.dashboard:
        return DashboardPage(
          reportWorkflowRepository: widget.reportWorkflowRepository,
          adminUserId: widget.adminUserId,
          iotDevicesRepository: widget.iotDevicesRepository,
          systemLogsRepository: widget.systemLogsRepository,
          manualOverrideApiClient: widget.manualOverrideApiClient,
        );
      case _NavSection.incidentVerification:
        return ReportsPage(
          reportWorkflowRepository: widget.reportWorkflowRepository,
          adminUserId: widget.adminUserId,
        );
      case _NavSection.userManagement:
        return UserManagementPage(
          userManagementRepository: widget.userManagementRepository,
          adminUserId: widget.adminUserId,
        );
      case _NavSection.systemLogs:
        return SystemLogsPage(
          systemLogsRepository: widget.systemLogsRepository,
        );
      case _NavSection.shelterLogistics:
        return ShelterLogisticsPage(
          shelterLogisticsRepository: widget.shelterLogisticsRepository,
          adminUserId: widget.adminUserId,
        );
      case _NavSection.iotDevices:
        return IotDevicesPage(repository: widget.iotDevicesRepository);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactSidebar = constraints.maxWidth < 1200;
        final sidebarWidth = compactSidebar ? 84.0 : 250.0;

        return Scaffold(
          body: Row(
            children: [
              Container(
                width: sidebarWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AdminColors.surface,
                      AdminColors.surfaceAlt,
                      AdminColors.background,
                    ],
                  ),
                  border: Border(
                    right: BorderSide(
                      color: AdminColors.primary.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AdminColors.primary.withValues(alpha: 0.07),
                      blurRadius: 24,
                      offset: const Offset(6, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 70,
                      child: Center(
                        child: compactSidebar
                            ? Icon(
                                Icons.water_drop_rounded,
                                color: AdminColors.primary,
                                size: 32,
                                shadows: [
                                  Shadow(
                                    color: AdminColors.primary.withValues(alpha: 0.85),
                                    blurRadius: 12,
                                  ),
                                ],
                              )
                            : ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AdminColors.primary,
                                    AdminColors.accent,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  l10n.appWordmark,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AdminColors.primary.withValues(alpha: 0.22),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _sections.length,
                        itemBuilder: (context, index) {
                          final section = _sections[index];
                          final label = _labelForSection(context, section);
                          final selected = index == _selectedIndex;

                          final tile = ListTile(
                            dense: true,
                            leading: Icon(_iconForSection(section)),
                            title: compactSidebar ? null : Text(label),
                            selected: selected,
                            selectedTileColor: AdminColors.surfaceAlt,
                            iconColor: selected ? AdminColors.primary : null,
                            textColor: selected ? AdminColors.primary : null,
                            onTap: () => setState(() => _selectedIndex = index),
                          );

                          if (!compactSidebar) return tile;
                          return Semantics(
                            button: true,
                            selected: selected,
                            label: label,
                            child: Tooltip(message: label, child: tile),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AdminColors.background.withValues(alpha: 0.92),
                        border: Border(
                          bottom: BorderSide(
                            color: AdminColors.primary.withValues(alpha: 0.28),
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AdminColors.accent.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            _labelForSection(context, _sections[_selectedIndex]),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          _ShellLanguageMenuButton(
                            currentLocale: Localizations.localeOf(context),
                          ),
                          const SizedBox(width: 8),
                          Semantics(
                            button: true,
                            label: l10n.signOut,
                            child: TextButton.icon(
                              onPressed: () async {
                                await widget.authService.signOut();
                                if (!context.mounted) return;
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.login);
                              },
                              icon: const Icon(Icons.logout),
                              label: Text(l10n.signOut),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildCurrentPage(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShellLanguageMenuButton extends StatelessWidget {
  const _ShellLanguageMenuButton({required this.currentLocale});

  final Locale currentLocale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopupMenuButton<String>(
      tooltip: l10n.languageLabel,
      initialValue: currentLocale.languageCode,
      onSelected: (value) => LocaleController.setLocale(Locale(value)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: Text(l10n.languageEnglish),
        ),
        PopupMenuItem(
          value: 'fil',
          child: Text(l10n.languageFilipino),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AdminColors.surfaceAlt,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AdminColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16),
            const SizedBox(width: 6),
            Text(
              currentLocale.languageCode.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NavSection {
  dashboard,
  incidentVerification,
  userManagement,
  systemLogs,
  shelterLogistics,
  iotDevices,
}