import 'package:flutter/material.dart';

import '../../../app_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/locale_controller.dart';
import '../../reports/data/report_workflow_repository.dart';
import '../../reports/presentation/reports_page.dart';
import '../../dashboard/presentation/dashboard_page.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({
    super.key,
    required this.reportWorkflowRepository,
    required this.adminUserId,
  });

  final ReportWorkflowRepository reportWorkflowRepository;
  final String adminUserId;

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _selectedIndex = 0;

  static const _sections = <_NavSection>[
    _NavSection.dashboard,
    _NavSection.incidentVerification,
    _NavSection.userManagement,
    _NavSection.systemLogs,
    _NavSection.shelterLogistics,
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
    }
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
    }
  }

  Widget _buildCurrentPage(BuildContext context) {
    final l10n = context.l10n;
    final section = _sections[_selectedIndex];

    switch (section) {
      case _NavSection.dashboard:
        return DashboardPage(
          reportWorkflowRepository: widget.reportWorkflowRepository,
          adminUserId: widget.adminUserId,
        );
      case _NavSection.incidentVerification:
        return ReportsPage(
          reportWorkflowRepository: widget.reportWorkflowRepository,
          adminUserId: widget.adminUserId,
        );
      case _NavSection.userManagement:
      case _NavSection.systemLogs:
      case _NavSection.shelterLogistics:
        return _PlaceholderPage(
          title: _labelForSection(context, section),
          placeholderSuffix: l10n.placeholderSuffix,
        );
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
                decoration: const BoxDecoration(
                  color: AdminColors.surface,
                  border: Border(
                    right: BorderSide(color: AdminColors.border),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 70,
                      child: Center(
                        child: compactSidebar
                            ? const Icon(Icons.water_drop, color: AdminColors.primary)
                            : Text(
                                l10n.appWordmark,
                                style: TextStyle(
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const Divider(height: 1, color: AdminColors.border),
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
                          return Tooltip(message: label, child: tile);
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
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AdminColors.border),
                        ),
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
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(l10n.signOut),
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

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.placeholderSuffix,
  });

  final String title;
  final String placeholderSuffix;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Text(
          '$title ($placeholderSuffix)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
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
}