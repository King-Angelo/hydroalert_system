import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../reports/data/report_workflow_repository.dart';
import '../data/mock_dashboard_data.dart';
import '../widgets/action_queue_panel.dart';
import '../widgets/mock_map_panel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.reportWorkflowRepository,
    required this.adminUserId,
  });

  final ReportWorkflowRepository reportWorkflowRepository;
  final String adminUserId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 1100;

        if (narrow) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const _SituationPane(),
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
                child: const _SituationPane(),
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
  const _SituationPane();

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
        const SizedBox(
          height: 330,
          child: MockMapPanel(assetPath: 'assets/images/mock_map.png'),
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
                ...mockActivityFeed.map((item) {
                  Color dotColor = AdminColors.primary;
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
                }),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label.toUpperCase(),
              style: const TextStyle(
                letterSpacing: 1.1,
                color: AdminColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  metric.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(metric.unit),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _localizedStatus(context),
              style: TextStyle(
                color: _statusColor(),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}