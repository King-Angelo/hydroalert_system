import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../alerts/data/manual_override_api_client.dart';
import '../../alerts/presentation/zone_manual_alert_card.dart';
import '../../iot_devices/data/iot_devices_repository.dart';
import '../../reports/data/report_workflow_repository.dart';
import '../../system_logs/data/system_logs_repository.dart';
import '../data/activity_log_mapper.dart';
import '../widgets/action_queue_panel.dart';
import '../widgets/iot_telemetry_strip.dart';
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
        IotTelemetryStrip(repository: iotDevicesRepository),
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