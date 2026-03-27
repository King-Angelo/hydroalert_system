import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../alerts/data/manual_override_api_client.dart';
import '../../alerts/presentation/zone_manual_alert_card.dart';
import '../../iot_devices/data/iot_devices_repository.dart';
import '../../reports/data/report_workflow_repository.dart';
import '../../system_logs/data/system_logs_repository.dart';
import '../data/activity_log_mapper.dart';
import '../data/mock_dashboard_data.dart';
import '../widgets/action_queue_panel.dart';
import '../widgets/operations_health_panel.dart';
import '../widgets/situation_map_panel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.reportWorkflowRepository,
    required this.adminUserId,
    required this.iotDevicesRepository,
    required this.systemLogsRepository,
    this.manualOverrideApiClient,
  });

  final ReportWorkflowRepository reportWorkflowRepository;
  final String adminUserId;
  final IotDevicesRepository iotDevicesRepository;
  final SystemLogsRepository systemLogsRepository;
  final ManualOverrideApiClient? manualOverrideApiClient;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 1100;

        if (narrow) {
          return SingleChildScrollView(
            child: Column(
              children: [
                OperationsHealthPanel(
                  iotDevicesRepository: iotDevicesRepository,
                ),
                const SizedBox(height: 16),
                _SituationPane(
                  systemLogsRepository: systemLogsRepository,
                  iotDevicesRepository: iotDevicesRepository,
                ),
                const SizedBox(height: 16),
                ZoneManualAlertCard(apiClient: manualOverrideApiClient),
                const SizedBox(height: 16),
                SizedBox(
                  height: 500,
                  child: ActionQueuePanel(
                    reportWorkflowRepository: reportWorkflowRepository,
                    adminUserId: adminUserId,
                  ),
                ),
              ],
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OperationsHealthPanel(
                      iotDevicesRepository: iotDevicesRepository,
                    ),
                    const SizedBox(height: 16),
                    _SituationPane(
                  systemLogsRepository: systemLogsRepository,
                  iotDevicesRepository: iotDevicesRepository,
                ),
                    const SizedBox(height: 16),
                    ZoneManualAlertCard(apiClient: manualOverrideApiClient),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ActionQueuePanel(
                reportWorkflowRepository: reportWorkflowRepository,
                adminUserId: adminUserId,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SituationPane extends StatelessWidget {
  const _SituationPane({
    required this.systemLogsRepository,
    required this.iotDevicesRepository,
  });

  final SystemLogsRepository systemLogsRepository;
  final IotDevicesRepository iotDevicesRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.situationPane, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: mockTelemetryMetrics
              .map((metric) => SizedBox(
                    width: 220,
                    child: _MetricCard(metric: metric),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 330,
          child: SituationMapPanel(
            iotDevicesRepository: iotDevicesRepository,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.activityFeed, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                StreamBuilder<List<SystemLogRecord>>(
                  stream: systemLogsRepository.watchRecentLogs(limit: 20),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        l10n.activityFeedLoadError('${snapshot.error}'),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final entries = activityEntriesFromSystemLogs(snapshot.data ?? []);
                    if (entries.isEmpty) {
                      return Text(
                        l10n.activityFeedEmpty,
                        style: const TextStyle(color: AdminColors.textMuted),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.map((item) {
                        var dotColor = AdminColors.primary;
                        if (item.severity == 'critical') dotColor = AdminColors.danger;
                        if (item.severity == 'warning') dotColor = AdminColors.warning;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${item.message} — ${item.timeAgo}'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final TelemetryMetric metric;

  Color _statusColor() {
    switch (metric.status.toLowerCase()) {
      case 'critical':
        return AdminColors.danger;
      case 'elevated':
      case 'heavy':
        return AdminColors.warning;
      default:
        return AdminColors.primary;
    }
  }

  String _localizedStatus(BuildContext context) {
    final l10n = context.l10n;
    switch (metric.status.toLowerCase()) {
      case 'critical':
        return l10n.statusCritical;
      case 'elevated':
        return l10n.statusElevated;
      case 'heavy':
        return l10n.statusHeavy;
      default:
        return metric.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: statusColor,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const SizedBox(width: 3),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.label.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AdminColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          metric.value,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            metric.unit,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AdminColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _localizedStatus(context),
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}