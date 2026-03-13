import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/mock_dashboard_data.dart';

class ActionQueuePanel extends StatelessWidget {
  const ActionQueuePanel({super.key, required this.items});

  final List<ActionQueueItem> items;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AdminColors.warning;
      case 'approved':
        return AdminColors.primary;
      case 'rejected':
        return AdminColors.danger;
      default:
        return AdminColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.actionQueue, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.actionQueuePlaceholder,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AdminColors.textMuted),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(color: AdminColors.border),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.reportId, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(item.zone),
                      const SizedBox(height: 2),
                      Text(
                        '${item.reporter} • ${item.timeAgo}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AdminColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: _statusColor(item.status)),
                            ),
                            child: Text(
                              _localizedStatus(l10n, item.status).toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: _statusColor(item.status),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: null,
                            child: Text(l10n.validate),
                          ),
                          OutlinedButton(
                            onPressed: null,
                            child: Text(l10n.reject),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedStatus(AppLocalizations l10n, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.statusPending;
      case 'approved':
        return l10n.statusApproved;
      case 'rejected':
        return l10n.statusRejected;
      default:
        return status;
    }
  }
}