import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/ui/app_feedback.dart';
import '../../../core/validation/admin_input_limits.dart';
import '../../../l10n/app_localizations.dart';
import '../../reports/data/report_workflow_repository.dart';

class ActionQueuePanel extends StatefulWidget {
  const ActionQueuePanel({
    super.key,
    required this.reportWorkflowRepository,
    required this.adminUserId,
  });

  final ReportWorkflowRepository reportWorkflowRepository;
  final String adminUserId;

  @override
  State<ActionQueuePanel> createState() => _ActionQueuePanelState();
}

class _ActionQueuePanelState extends State<ActionQueuePanel> {
  String? _submittingReportId;

  Future<void> _reviewReport({
    required IncidentReportRecord report,
    required ReportReviewDecision decision,
  }) async {
    final notes = await _openReviewNotesDialog(
      isValidate: decision == ReportReviewDecision.validated,
      reportId: report.reportId,
    );
    if (notes == null) return;

    setState(() => _submittingReportId = report.reportId);
    try {
      await widget.reportWorkflowRepository.reviewReport(
        reportId: report.reportId,
        decision: decision,
        adminId: widget.adminUserId,
        reviewNotes: notes,
      );
      if (!mounted) return;
      final msg = decision == ReportReviewDecision.validated
          ? context.l10n.reportReviewValidated(report.reportId)
          : context.l10n.reportReviewRejected(report.reportId);
      showAppSnackBar(context, msg);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.l10n.errorWithDetails(truncateErrorDetails(error)),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submittingReportId = null);
      }
    }
  }

  Future<String?> _openReviewNotesDialog({
    required bool isValidate,
    required String reportId,
  }) async {
    final controller = TextEditingController();
    final l10n = context.l10n;

    final notes = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isValidate ? '${l10n.validate} $reportId' : '${l10n.reject} $reportId'),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            maxLength: AdminInputLimits.reviewNotesMaxLength,
            decoration: InputDecoration(
              labelText: l10n.reviewNotesLabel,
              hintText: isValidate
                  ? l10n.reviewNotesHintValidate
                  : l10n.reviewNotesHintReject,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (!isValidate && text.isEmpty) {
                  return;
                }
                Navigator.of(context).pop(text);
              },
              child: Text(isValidate ? l10n.validate : l10n.reject),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return notes;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AdminColors.warning;
      case 'validated':
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
              child: StreamBuilder<List<IncidentReportRecord>>(
                stream: widget.reportWorkflowRepository.watchPendingReports(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '${l10n.actionQueueLoadError}\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AdminColors.danger),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.actionQueueNoPending,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AdminColors.textMuted),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AdminColors.border),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSubmitting = _submittingReportId == item.reportId;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.reportId,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(item.zone),
                          const SizedBox(height: 2),
                          Text(
                            '${item.residentId} • ${_formatAge(item.createdAt)}',
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: _statusColor(item.status),
                                  ),
                                ),
                                child: Text(
                                  _localizedStatus(l10n, item.status)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _statusColor(item.status),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => _reviewReport(
                                        report: item,
                                        decision: ReportReviewDecision.validated,
                                      ),
                                child: Text(l10n.validate),
                              ),
                              OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => _reviewReport(
                                        report: item,
                                        decision: ReportReviewDecision.rejected,
                                      ),
                                child: Text(l10n.reject),
                              ),
                              if (isSubmitting)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
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
      case 'validated':
        return l10n.statusValidated;
      case 'approved':
        return l10n.statusApproved;
      case 'rejected':
        return l10n.statusRejected;
      default:
        return status;
    }
  }

  String _formatAge(DateTime createdAt) {
    final l10n = context.l10n;
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return l10n.timeAgoJustNow;
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
    return l10n.timeAgoDays(diff.inDays);
  }
}