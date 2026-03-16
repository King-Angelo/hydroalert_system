import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/report_workflow_repository.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({
    super.key,
    required this.reportWorkflowRepository,
    required this.adminUserId,
  });

  final ReportWorkflowRepository reportWorkflowRepository;
  final String adminUserId;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const _pageSize = 20;
  static const _statusFilters = <String>[
    'Pending',
    'Validated',
    'Rejected',
    'All',
  ];

  final Map<int, IncidentReportPageResult> _pages = {};
  final List<DateTime?> _startCursors = [null];
  int _pageIndex = 0;
  String _statusFilter = 'Pending';
  bool _loading = true;
  String? _error;
  String? _submittingReportId;
  IncidentReportRecord? _selected;

  @override
  void initState() {
    super.initState();
    _loadPage(pageIndex: 0);
  }

  Future<void> _loadPage({required int pageIndex, bool force = false}) async {
    if (!force && _pages.containsKey(pageIndex)) {
      _syncSelectionWithCurrentPage();
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await widget.reportWorkflowRepository.fetchReportsPage(
        statusFilter: _statusFilter,
        pageSize: _pageSize,
        startAfterCreatedAt: _startCursors[pageIndex],
      );

      if (!mounted) return;
      setState(() {
        _pages[pageIndex] = result;
        if (_startCursors.length == pageIndex + 1) {
          _startCursors.add(result.nextCursorCreatedAt);
        } else {
          _startCursors[pageIndex + 1] = result.nextCursorCreatedAt;
        }
        _loading = false;
      });
      _syncSelectionWithCurrentPage();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  void _syncSelectionWithCurrentPage() {
    final page = _pages[_pageIndex];
    if (page == null || page.items.isEmpty) {
      setState(() => _selected = null);
      return;
    }

    final selectedId = _selected?.reportId;
    final stillVisible =
        selectedId != null && page.items.any((item) => item.reportId == selectedId);
    if (!stillVisible) {
      setState(() => _selected = page.items.first);
    }
  }

  void _changeFilter(String nextFilter) {
    if (_statusFilter == nextFilter) return;
    setState(() {
      _statusFilter = nextFilter;
      _pageIndex = 0;
      _pages.clear();
      _startCursors
        ..clear()
        ..add(null);
      _selected = null;
      _error = null;
    });
    _loadPage(pageIndex: 0, force: true);
  }

  Future<void> _goToNextPage() async {
    final current = _pages[_pageIndex];
    if (current == null || !current.hasNextPage) return;

    final nextIndex = _pageIndex + 1;
    setState(() => _pageIndex = nextIndex);
    await _loadPage(pageIndex: nextIndex);
  }

  void _goToPreviousPage() {
    if (_pageIndex == 0) return;
    setState(() {
      _pageIndex -= 1;
      _error = null;
    });
    _syncSelectionWithCurrentPage();
  }

  Future<void> _reviewSelected(ReportReviewDecision decision) async {
    final report = _selected;
    if (report == null || report.status != 'Pending') return;

    final notes = await _openReviewNotesDialog(
      reportId: report.reportId,
      isValidate: decision == ReportReviewDecision.validated,
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
      final actionText = decision == ReportReviewDecision.validated
          ? context.l10n.validate.toLowerCase()
          : context.l10n.reject.toLowerCase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report ${report.reportId} $actionText.')),
      );

      _pages.remove(_pageIndex);
      await _loadPage(pageIndex: _pageIndex, force: true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to review report: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingReportId = null);
      }
    }
  }

  Future<String?> _openReviewNotesDialog({
    required String reportId,
    required bool isValidate,
  }) async {
    final controller = TextEditingController();
    final l10n = context.l10n;
    String? validationError;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isValidate
                    ? '${l10n.validate} $reportId'
                    : '${l10n.reject} $reportId',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Review notes',
                      hintText: isValidate
                          ? 'Optional validation remarks.'
                          : 'Reason for rejecting this report.',
                      errorText: validationError,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (!isValidate && text.isEmpty) {
                      setDialogState(() {
                        validationError = 'Rejection reason is required.';
                      });
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
      },
    );

    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_pageIndex];
    final items = currentPage?.items ?? const <IncidentReportRecord>[];
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 1200;

        final listPane = _buildListPane(
          context: context,
          l10n: l10n,
          items: items,
          currentPage: currentPage,
        );
        final detailPane = _buildDetailPane(context: context, l10n: l10n);

        if (narrow) {
          return Column(
            children: [
              Expanded(flex: 6, child: listPane),
              const SizedBox(height: 12),
              Expanded(flex: 5, child: detailPane),
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 6, child: listPane),
            const SizedBox(width: 12),
            Expanded(flex: 4, child: detailPane),
          ],
        );
      },
    );
  }

  Widget _buildListPane({
    required BuildContext context,
    required AppLocalizations l10n,
    required List<IncidentReportRecord> items,
    required IncidentReportPageResult? currentPage,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _statusFilters.map((status) {
                final selected = _statusFilter == status;
                return ChoiceChip(
                  label: Text(_statusLabel(l10n, status)),
                  selected: selected,
                  onSelected: (_) => _changeFilter(status),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            _buildTableHeader(context),
            const Divider(color: AdminColors.border, height: 1),
            Expanded(
              child: _buildTableBody(
                context: context,
                items: items,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Page ${_pageIndex + 1}'),
                const Spacer(),
                OutlinedButton(
                  onPressed: _pageIndex > 0 && !_loading ? _goToPreviousPage : null,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: !_loading && (currentPage?.hasNextPage ?? false)
                      ? _goToNextPage
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: AdminColors.surfaceAlt,
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('report_id')),
          Expanded(flex: 3, child: Text('created_at')),
          Expanded(flex: 2, child: Text('zone')),
          Expanded(flex: 3, child: Text('resident_id')),
          Expanded(flex: 2, child: Text('status')),
        ],
      ),
    );
  }

  Widget _buildTableBody({
    required BuildContext context,
    required List<IncidentReportRecord> items,
  }) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Unable to load reports.\n$_error',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AdminColors.danger),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No reports found for $_statusFilter.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AdminColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: AdminColors.border),
      itemBuilder: (context, index) {
        final report = items[index];
        final selected = _selected?.reportId == report.reportId;
        return Material(
          color: selected ? AdminColors.surfaceAlt : Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selected = report),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(report.reportId)),
                  Expanded(flex: 3, child: Text(_formatDateTime(report.createdAt))),
                  Expanded(flex: 2, child: Text(report.zone)),
                  Expanded(flex: 3, child: Text(report.residentId)),
                  Expanded(
                    flex: 2,
                    child: Text(
                      report.status,
                      style: TextStyle(color: _statusColor(report.status)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailPane({
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    final report = _selected;

    if (report == null) {
      return Card(
        child: Center(
          child: Text(
            'Select a report to inspect details.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AdminColors.textMuted),
          ),
        ),
      );
    }

    final isPending = report.status == 'Pending';
    final isSubmitting = _submittingReportId == report.reportId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report ${report.reportId}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _kv('Status', report.status),
              _kv('Created At', _formatDateTime(report.createdAt)),
              _kv('Zone', report.zone),
              _kv('Resident', report.residentId),
              _kv('Coordinates', _formatCoordinates(report)),
              const SizedBox(height: 10),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(report.description ?? '-'),
              const SizedBox(height: 12),
              Text(
                'Photo Evidence',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              _buildPhotoPreview(report),
              const SizedBox(height: 12),
              Text(
                'Reviewer History',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              _kv('status', report.status),
              _kv('reviewed_by', report.reviewedBy ?? '-'),
              _kv(
                'reviewed_at',
                report.reviewedAt == null ? '-' : _formatDateTime(report.reviewedAt!),
              ),
              _kv('review_notes', report.reviewNotes ?? '-'),
              const SizedBox(height: 12),
              if (!isPending)
                Text(
                  'Decision already finalized. Reopen is blocked in v1.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AdminColors.warning),
                ),
              Row(
                children: [
                  FilledButton(
                    onPressed: isPending && !isSubmitting
                        ? () => _reviewSelected(ReportReviewDecision.validated)
                        : null,
                    child: Text(l10n.validate),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: isPending && !isSubmitting
                        ? () => _reviewSelected(ReportReviewDecision.rejected)
                        : null,
                    child: Text(l10n.reject),
                  ),
                  if (isSubmitting) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(IncidentReportRecord report) {
    final url = report.photoUrl;
    if (url == null || url.isEmpty) {
      return Container(
        height: 180,
        color: AdminColors.surfaceAlt,
        alignment: Alignment.center,
        child: const Text('No photo URL'),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AdminColors.surfaceAlt,
                  alignment: Alignment.center,
                  child: const Text('Unable to load photo'),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AdminColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'Pending':
        return l10n.statusPending;
      case 'Validated':
        return l10n.statusValidated;
      case 'Rejected':
        return l10n.statusRejected;
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AdminColors.warning;
      case 'validated':
        return AdminColors.primary;
      case 'rejected':
        return AdminColors.danger;
      default:
        return AdminColors.textMuted;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day $hour:$minute';
  }

  String _formatCoordinates(IncidentReportRecord report) {
    final lat = report.latitude;
    final lng = report.longitude;
    if (lat == null || lng == null) return '-';
    return '$lat, $lng';
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              key,
              style: const TextStyle(
                color: AdminColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
