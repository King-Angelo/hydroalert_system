import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../data/system_logs_repository.dart';

class SystemLogsPage extends StatefulWidget {
  const SystemLogsPage({
    super.key,
    required this.systemLogsRepository,
  });

  final SystemLogsRepository systemLogsRepository;

  @override
  State<SystemLogsPage> createState() => _SystemLogsPageState();
}

class _SystemLogsPageState extends State<SystemLogsPage> {
  static const _uiPageSize = 20;
  static const _remotePageSize = 100;

  final _searchController = TextEditingController();
  final _actionController = TextEditingController();
  final _adminController = TextEditingController();
  final _targetController = TextEditingController();

  final _jsonEncoder = const JsonEncoder.withIndent('  ');

  StreamSubscription<List<SystemLogRecord>>? _recentLogsSub;

  List<SystemLogRecord> _logs = [];
  DateTime? _nextRemoteCursor;
  bool _hasMoreRemote = true;

  bool _loadingInitial = true;
  bool _loadingMore = false;
  String? _error;

  int _pageIndex = 0;
  SystemLogRecord? _selected;

  String _typeFilter = 'All';
  String _searchQuery = '';
  String _actionQuery = '';
  String _adminIdQuery = '';
  String _targetIdQuery = '';
  _DateRangeFilter _dateRangeFilter = _DateRangeFilter.last7Days;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _recentLogsSub?.cancel();
    _searchController.dispose();
    _actionController.dispose();
    _adminController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _fetchMore(reset: true);
    _subscribeToRecentLogs();
  }

  void _subscribeToRecentLogs() {
    _recentLogsSub?.cancel();
    _recentLogsSub = widget.systemLogsRepository
        .watchRecentLogs(limit: _remotePageSize)
        .listen(
          (recent) {
            if (!mounted) return;
            setState(() {
              _logs = _mergeById(_logs, recent);
              _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              _clampPageIndex();
              _syncSelectionWithVisible(triggerSetState: false);
            });
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _error = '$error';
            });
          },
        );
  }

  Future<void> _fetchMore({bool reset = false}) async {
    if (_loadingMore) return;
    if (!reset && !_hasMoreRemote) return;

    setState(() {
      if (reset) {
        _loadingInitial = true;
        _error = null;
        _logs = [];
        _nextRemoteCursor = null;
        _hasMoreRemote = true;
        _pageIndex = 0;
        _selected = null;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final result = await widget.systemLogsRepository.fetchLogsPage(
        pageSize: _remotePageSize,
        startAfterTimestamp: _nextRemoteCursor,
      );
      if (!mounted) return;
      setState(() {
        _logs = _mergeById(_logs, result.items);
        _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _hasMoreRemote = result.hasNextPage;
        _nextRemoteCursor = result.nextCursorTimestamp;
        _loadingInitial = false;
        _loadingMore = false;
        _clampPageIndex();
        _syncSelectionWithVisible(triggerSetState: false);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingInitial = false;
        _loadingMore = false;
        _error = '$error';
      });
    }
  }

  List<SystemLogRecord> _mergeById(
    List<SystemLogRecord> base,
    List<SystemLogRecord> incoming,
  ) {
    final byId = <String, SystemLogRecord>{};
    for (final item in base) {
      byId[item.logId] = item;
    }
    for (final item in incoming) {
      byId[item.logId] = item;
    }
    return byId.values.toList();
  }

  List<SystemLogRecord> get _filteredLogs {
    final lowerSearch = _searchQuery.toLowerCase();
    final lowerAction = _actionQuery.toLowerCase();
    final lowerAdmin = _adminIdQuery.toLowerCase();
    final lowerTarget = _targetIdQuery.toLowerCase();
    final cutoff = _dateCutoff(_dateRangeFilter);

    final filtered = _logs.where((log) {
      if (_typeFilter != 'All' && log.type != _typeFilter) {
        return false;
      }

      if (cutoff != null && log.timestamp.isBefore(cutoff)) {
        return false;
      }

      if (lowerAction.isNotEmpty &&
          !log.action.toLowerCase().contains(lowerAction)) {
        return false;
      }

      if (lowerAdmin.isNotEmpty &&
          !(log.adminId ?? '').toLowerCase().contains(lowerAdmin)) {
        return false;
      }

      if (lowerTarget.isNotEmpty) {
        final targetTokens = <String>[
          log.targetId ?? '',
          log.targetReportId ?? '',
          log.targetUserId ?? '',
          log.targetSensorId ?? '',
        ].map((value) => value.toLowerCase()).join(' ');
        if (!targetTokens.contains(lowerTarget)) {
          return false;
        }
      }

      if (lowerSearch.isNotEmpty) {
        final corpus = <String>[
          log.logId,
          log.type,
          log.action,
          log.adminId ?? '',
          log.targetId ?? '',
          log.targetReportId ?? '',
          log.targetUserId ?? '',
          log.targetSensorId ?? '',
          log.notes ?? '',
        ].join(' ').toLowerCase();
        if (!corpus.contains(lowerSearch)) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  List<SystemLogRecord> get _currentPageItems {
    final filtered = _filteredLogs;
    if (filtered.isEmpty) return const [];
    final start = _pageIndex * _uiPageSize;
    if (start >= filtered.length) return const [];
    final end = min(start + _uiPageSize, filtered.length);
    return filtered.sublist(start, end);
  }

  int get _totalPages {
    final count = _filteredLogs.length;
    if (count == 0) return 1;
    return (count / _uiPageSize).ceil();
  }

  DateTime? _dateCutoff(_DateRangeFilter range) {
    final now = DateTime.now();
    switch (range) {
      case _DateRangeFilter.last24Hours:
        return now.subtract(const Duration(hours: 24));
      case _DateRangeFilter.last7Days:
        return now.subtract(const Duration(days: 7));
      case _DateRangeFilter.last30Days:
        return now.subtract(const Duration(days: 30));
      case _DateRangeFilter.all:
        return null;
    }
  }

  Future<void> _goToNextPage() async {
    final filteredCount = _filteredLogs.length;
    final targetStart = (_pageIndex + 1) * _uiPageSize;

    if (targetStart < filteredCount) {
      setState(() => _pageIndex += 1);
      _syncSelectionWithVisible();
      return;
    }

    while (_hasMoreRemote) {
      await _fetchMore();
      final refreshedCount = _filteredLogs.length;
      if ((_pageIndex + 1) * _uiPageSize < refreshedCount) {
        if (!mounted) return;
        setState(() => _pageIndex += 1);
        _syncSelectionWithVisible();
        return;
      }
      if (_loadingMore) break;
    }
  }

  void _goToPreviousPage() {
    if (_pageIndex == 0) return;
    setState(() => _pageIndex -= 1);
    _syncSelectionWithVisible();
  }

  void _applyFilters() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _actionQuery = _actionController.text.trim();
      _adminIdQuery = _adminController.text.trim();
      _targetIdQuery = _targetController.text.trim();
      _pageIndex = 0;
      _error = null;
    });
    _clampPageIndex();
    _syncSelectionWithVisible();
  }

  void _clearFilters() {
    _searchController.clear();
    _actionController.clear();
    _adminController.clear();
    _targetController.clear();
    setState(() {
      _typeFilter = 'All';
      _searchQuery = '';
      _actionQuery = '';
      _adminIdQuery = '';
      _targetIdQuery = '';
      _dateRangeFilter = _DateRangeFilter.last7Days;
      _pageIndex = 0;
      _error = null;
    });
    _syncSelectionWithVisible();
  }

  void _clampPageIndex() {
    final pages = _totalPages;
    if (_pageIndex >= pages) {
      _pageIndex = max(0, pages - 1);
    }
  }

  void _syncSelectionWithVisible({bool triggerSetState = true}) {
    final pageItems = _currentPageItems;
    if (pageItems.isEmpty) {
      if (_selected == null) return;
      if (triggerSetState) {
        setState(() => _selected = null);
      } else {
        _selected = null;
      }
      return;
    }

    final selectedId = _selected?.logId;
    final stillVisible =
        selectedId != null && pageItems.any((item) => item.logId == selectedId);
    if (!stillVisible) {
      if (triggerSetState) {
        setState(() => _selected = pageItems.first);
      } else {
        _selected = pageItems.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 1280;
        final listPane = _buildListPane(context);
        final detailPane = _buildDetailPane(context);

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

  Widget _buildListPane(BuildContext context) {
    final items = _currentPageItems;
    final types = <String>{
      'All',
      ..._logs.map((log) => log.type),
    }.toList()
      ..sort();

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
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _typeFilter,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: types
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _typeFilter = value;
                        _pageIndex = 0;
                      });
                      _syncSelectionWithVisible();
                    },
                  ),
                ),
                _dateChip(_DateRangeFilter.last24Hours, 'Last 24h'),
                _dateChip(_DateRangeFilter.last7Days, 'Last 7d'),
                _dateChip(_DateRangeFilter.last30Days, 'Last 30d'),
                _dateChip(_DateRangeFilter.all, 'All time'),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _queryField(
                  controller: _searchController,
                  label: 'Search notes/ids',
                ),
                _queryField(
                  controller: _actionController,
                  label: 'Filter action',
                ),
                _queryField(
                  controller: _adminController,
                  label: 'Filter admin_id',
                ),
                _queryField(
                  controller: _targetController,
                  label: 'Filter target_id',
                ),
                FilledButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply'),
                ),
                OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTableHeader(),
            const Divider(color: AdminColors.border, height: 1),
            Expanded(child: _buildTableBody(context, items)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Page ${_pageIndex + 1} / $_totalPages'),
                const SizedBox(width: 12),
                Text(
                  '${_filteredLogs.length} matching logs',
                  style: const TextStyle(color: AdminColors.textMuted, fontSize: 12),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _pageIndex > 0 && !_loadingInitial && !_loadingMore
                      ? _goToPreviousPage
                      : null,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: !_loadingInitial && !_loadingMore
                      ? _goToNextPage
                      : null,
                  child: Text(_loadingMore ? 'Loading...' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateChip(_DateRangeFilter value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _dateRangeFilter == value,
      onSelected: (_) {
        setState(() {
          _dateRangeFilter = value;
          _pageIndex = 0;
        });
        _syncSelectionWithVisible();
      },
    );
  }

  Widget _queryField({
    required TextEditingController controller,
    required String label,
  }) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (_) => _applyFilters(),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: AdminColors.surfaceAlt,
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('timestamp')),
          Expanded(flex: 2, child: Text('type')),
          Expanded(flex: 2, child: Text('action')),
          Expanded(flex: 2, child: Text('admin_id')),
          Expanded(flex: 3, child: Text('target_id')),
        ],
      ),
    );
  }

  Widget _buildTableBody(BuildContext context, List<SystemLogRecord> items) {
    if (_loadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Unable to load system logs.\n$_error',
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
          'No logs found for the current filters.',
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
        final log = items[index];
        final selected = _selected?.logId == log.logId;
        return Material(
          color: selected ? AdminColors.surfaceAlt : Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selected = log),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(_formatDateTime(log.timestamp))),
                  Expanded(flex: 2, child: Text(log.type)),
                  Expanded(flex: 2, child: Text(log.action)),
                  Expanded(flex: 2, child: Text(log.adminId ?? '-')),
                  Expanded(
                    flex: 3,
                    child: Text(
                      log.targetId ?? '-',
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildDetailPane(BuildContext context) {
    final selected = _selected;
    if (selected == null) {
      return Card(
        child: Center(
          child: Text(
            'Select a log entry to inspect full payload.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AdminColors.textMuted),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(selected.logId, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _kv('timestamp', _formatDateTime(selected.timestamp)),
              _kv('type', selected.type),
              _kv('action', selected.action),
              _kv('admin_id', selected.adminId ?? '-'),
              _kv('target_id', selected.targetId ?? '-'),
              _kv('target_report_id', selected.targetReportId ?? '-'),
              _kv('target_user_id', selected.targetUserId ?? '-'),
              _kv('target_sensor_id', selected.targetSensorId ?? '-'),
              const SizedBox(height: 10),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(selected.notes ?? '-'),
              const SizedBox(height: 12),
              Text(
                'Before',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              _jsonPanel(selected.before),
              const SizedBox(height: 12),
              Text(
                'After',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              _jsonPanel(selected.after),
              const SizedBox(height: 12),
              Text(
                'Raw Payload',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              _jsonPanel(selected.raw),
              const SizedBox(height: 12),
              Text(
                'System logs are immutable records in v1 (read-only).',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AdminColors.warning),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jsonPanel(Map<String, dynamic>? payload) {
    final text = payload == null || payload.isEmpty ? '-' : _safeJson(payload);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AdminColors.surfaceAlt,
        border: Border.all(color: AdminColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }

  String _safeJson(Map<String, dynamic> payload) {
    try {
      return _jsonEncoder.convert(_normalizeForJson(payload));
    } catch (_) {
      return payload.toString();
    }
  }

  dynamic _normalizeForJson(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      final normalized = <String, dynamic>{};
      value.forEach((key, entry) {
        normalized[key.toString()] = _normalizeForJson(entry);
      });
      return normalized;
    }
    if (value is Iterable) {
      return value.map(_normalizeForJson).toList();
    }
    return value.toString();
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute:$second';
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
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

enum _DateRangeFilter {
  last24Hours,
  last7Days,
  last30Days,
  all,
}
