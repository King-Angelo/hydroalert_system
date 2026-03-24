import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/ui/app_feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../data/shelter_logistics_repository.dart';

class ShelterLogisticsPage extends StatefulWidget {
  const ShelterLogisticsPage({
    super.key,
    required this.shelterLogisticsRepository,
    required this.adminUserId,
  });

  final ShelterLogisticsRepository shelterLogisticsRepository;
  final String adminUserId;

  @override
  State<ShelterLogisticsPage> createState() => _ShelterLogisticsPageState();
}

class _ShelterLogisticsPageState extends State<ShelterLogisticsPage> {
  static const _pageSize = 20;
  static const _statusFilters = <String>['All', 'Open', 'Closed'];
  static const _zoneFilters = <String>['All', 'North', 'Central', 'Southern'];

  final _searchController = TextEditingController();

  int _pageIndex = 0;
  String _statusFilter = 'All';
  String _zoneFilter = 'All';
  ShelterOccupancyFilter _occupancyFilter = ShelterOccupancyFilter.all;
  String _searchQuery = '';
  String? _submittingShelterId;
  ShelterRecord? _selected;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ShelterRecord> _applyFilters(List<ShelterRecord> source) {
    final query = _searchQuery.toLowerCase();
    final filtered = source.where((shelter) {
      if (!shelter.isActive) return false;
      if (_statusFilter != 'All' && shelter.status != _statusFilter) return false;
      if (_zoneFilter != 'All' && (shelter.zone ?? '') != _zoneFilter) return false;

      switch (_occupancyFilter) {
        case ShelterOccupancyFilter.all:
          break;
        case ShelterOccupancyFilter.available:
          if (shelter.occupancyRatio >= 0.8) return false;
          break;
        case ShelterOccupancyFilter.nearCapacity:
          if (shelter.occupancyRatio < 0.8 || shelter.occupancyRatio >= 1.0) {
            return false;
          }
          break;
        case ShelterOccupancyFilter.full:
          if (shelter.currentOccupancy < shelter.capacity) return false;
          break;
      }

      if (query.isNotEmpty) {
        final corpus = <String>[
          shelter.name,
          shelter.contact ?? '',
          shelter.shelterId,
        ].join(' ').toLowerCase();
        if (!corpus.contains(query)) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final byZone = (a.zone ?? '').compareTo(b.zone ?? '');
        if (byZone != 0) return byZone;
        return a.name.compareTo(b.name);
      });

    return filtered;
  }

  int _totalPages(List<ShelterRecord> filtered) {
    if (filtered.isEmpty) return 1;
    return (filtered.length / _pageSize).ceil();
  }

  String _statusFilterLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'All':
        return l10n.shelterFilterAll;
      case 'Open':
        return l10n.shelterOpen;
      case 'Closed':
        return l10n.shelterClosed;
      default:
        return value;
    }
  }

  String _occupancyFilterLabel(
    AppLocalizations l10n,
    ShelterOccupancyFilter f,
  ) {
    switch (f) {
      case ShelterOccupancyFilter.all:
        return l10n.shelterOccupancyFilterAll;
      case ShelterOccupancyFilter.available:
        return l10n.shelterOccupancyFilterAvailable;
      case ShelterOccupancyFilter.nearCapacity:
        return l10n.shelterOccupancyFilterNearCap;
      case ShelterOccupancyFilter.full:
        return l10n.shelterOccupancyFilterFull;
    }
  }

  List<ShelterRecord> _pageItems(List<ShelterRecord> filtered) {
    final totalPages = _totalPages(filtered);
    if (_pageIndex >= totalPages) {
      _pageIndex = totalPages - 1;
    }
    if (_pageIndex < 0) _pageIndex = 0;

    final start = _pageIndex * _pageSize;
    if (start >= filtered.length) return const [];
    final end = (start + _pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  void _syncSelection(List<ShelterRecord> visible) {
    if (visible.isEmpty) {
      if (_selected != null) {
        setState(() => _selected = null);
      }
      return;
    }
    final selectedId = _selected?.shelterId;
    final stillVisible =
        selectedId != null && visible.any((shelter) => shelter.shelterId == selectedId);
    if (!stillVisible) {
      setState(() => _selected = visible.first);
    }
  }

  Future<void> _toggleStatus(ShelterRecord shelter) async {
    final nextStatus = shelter.status == 'Open' ? 'Closed' : 'Open';
    setState(() => _submittingShelterId = shelter.shelterId);
    try {
      await widget.shelterLogisticsRepository.updateShelterStatus(
        shelterId: shelter.shelterId,
        nextStatus: nextStatus,
        adminId: widget.adminUserId,
      );
      if (!mounted) return;
      final l10n = context.l10n;
      final statusWord =
          nextStatus == 'Open' ? l10n.shelterOpen : l10n.shelterClosed;
      showAppSnackBar(
        context,
        l10n.shelterStatusUpdated(shelter.shelterId, statusWord),
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.l10n.errorWithDetails(
          '${context.l10n.shelterStatusUpdateFailed} ${truncateErrorDetails(error)}',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submittingShelterId = null);
      }
    }
  }

  Future<void> _editCapacity(ShelterRecord shelter) async {
    final l10n = context.l10n;
    final value = await _openNumberDialog(
      l10n: l10n,
      title: l10n.shelterUpdateCapacityTitle,
      label: l10n.shelterLabelCapacity,
      initialValue: shelter.capacity,
    );
    if (value == null) return;

    setState(() => _submittingShelterId = shelter.shelterId);
    try {
      await widget.shelterLogisticsRepository.updateShelterCapacity(
        shelterId: shelter.shelterId,
        nextCapacity: value,
        adminId: widget.adminUserId,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.l10n.shelterCapacityUpdated(shelter.shelterId),
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.l10n.errorWithDetails(
          '${context.l10n.shelterCapacityUpdateFailed} ${truncateErrorDetails(error)}',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submittingShelterId = null);
      }
    }
  }

  Future<void> _editOccupancy(ShelterRecord shelter) async {
    final l10n = context.l10n;
    final value = await _openNumberDialog(
      l10n: l10n,
      title: l10n.shelterUpdateOccupancyTitle,
      label: l10n.shelterLabelOccupancy,
      initialValue: shelter.currentOccupancy,
    );
    if (value == null) return;

    setState(() => _submittingShelterId = shelter.shelterId);
    try {
      await widget.shelterLogisticsRepository.updateShelterOccupancy(
        shelterId: shelter.shelterId,
        nextOccupancy: value,
        adminId: widget.adminUserId,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.l10n.shelterOccupancyUpdated(shelter.shelterId),
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.l10n.errorWithDetails(
          '${context.l10n.shelterOccupancyUpdateFailed} ${truncateErrorDetails(error)}',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submittingShelterId = null);
      }
    }
  }

  Future<void> _softDelete(ShelterRecord shelter) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.shelterSoftDeleteTitle),
        content: Text(l10n.shelterSoftDeleteConfirm(shelter.shelterId)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _submittingShelterId = shelter.shelterId);
    try {
      await widget.shelterLogisticsRepository.softDeleteShelter(
        shelterId: shelter.shelterId,
        adminId: widget.adminUserId,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.l10n.shelterSoftDeleted(shelter.shelterId),
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.l10n.errorWithDetails(
          '${context.l10n.shelterSoftDeleteFailed} ${truncateErrorDetails(error)}',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submittingShelterId = null);
      }
    }
  }

  Future<int?> _openNumberDialog({
    required AppLocalizations l10n,
    required String title,
    required String label,
    required int initialValue,
  }) async {
    final controller = TextEditingController(text: '$initialValue');
    String? validationError;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: label,
                  errorText: validationError,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final value = int.tryParse(controller.text.trim());
                    if (value == null || value < 0) {
                      setDialogState(() {
                        validationError = l10n.validationIntegerNonNegative;
                      });
                      return;
                    }
                    Navigator.of(context).pop(value);
                  },
                  child: Text(l10n.commonSave),
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
    return StreamBuilder<List<ShelterRecord>>(
      stream: widget.shelterLogisticsRepository.watchShelters(),
      builder: (context, snapshot) {
        final l10n = context.l10n;
        if (snapshot.hasError) {
          return Card(
            child: Center(
              child: Text(
                '${l10n.shelterLoadError}\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AdminColors.danger),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Card(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final filtered = _applyFilters(snapshot.data!);
        final pageItems = _pageItems(filtered);
        _syncSelection(pageItems);

        return LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 1260;
            final listPane = _buildListPane(l10n, filtered, pageItems);
            final detailPane = _buildDetailPane(l10n);

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
      },
    );
  }

  Widget _buildListPane(
    AppLocalizations l10n,
    List<ShelterRecord> filtered,
    List<ShelterRecord> pageItems,
  ) {
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
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: _statusFilter,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.shelterFilterStatusLabel,
                    ),
                    items: _statusFilters
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(_statusFilterLabel(l10n, value)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _statusFilter = value;
                        _pageIndex = 0;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: _zoneFilter,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.shelterFilterZoneLabel,
                    ),
                    items: _zoneFilters
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value == 'All'
                                    ? l10n.shelterFilterAll
                                    : value,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _zoneFilter = value;
                        _pageIndex = 0;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<ShelterOccupancyFilter>(
                    initialValue: _occupancyFilter,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.shelterOccupancyLevelLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: ShelterOccupancyFilter.all,
                        child: Text(_occupancyFilterLabel(
                          l10n,
                          ShelterOccupancyFilter.all,
                        )),
                      ),
                      DropdownMenuItem(
                        value: ShelterOccupancyFilter.available,
                        child: Text(_occupancyFilterLabel(
                          l10n,
                          ShelterOccupancyFilter.available,
                        )),
                      ),
                      DropdownMenuItem(
                        value: ShelterOccupancyFilter.nearCapacity,
                        child: Text(_occupancyFilterLabel(
                          l10n,
                          ShelterOccupancyFilter.nearCapacity,
                        )),
                      ),
                      DropdownMenuItem(
                        value: ShelterOccupancyFilter.full,
                        child: Text(_occupancyFilterLabel(
                          l10n,
                          ShelterOccupancyFilter.full,
                        )),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _occupancyFilter = value;
                        _pageIndex = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: l10n.shelterSearchByNameOrContact,
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                        _pageIndex = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text.trim();
                      _pageIndex = 0;
                    });
                  },
                  child: Text(l10n.commonApply),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _pageIndex = 0;
                    });
                  },
                  child: Text(l10n.commonClear),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTableHeader(l10n),
            const Divider(color: AdminColors.border, height: 1),
            Expanded(child: _buildTableBody(l10n, pageItems)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  l10n.paginationPageOf(
                    _pageIndex + 1,
                    _totalPages(filtered),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.shelterActiveCount(filtered.length),
                  style:
                      const TextStyle(color: AdminColors.textMuted, fontSize: 12),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _pageIndex > 0
                      ? () => setState(() => _pageIndex -= 1)
                      : null,
                  child: Text(l10n.commonPrevious),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: (_pageIndex + 1) < _totalPages(filtered)
                      ? () => setState(() => _pageIndex += 1)
                      : null,
                  child: Text(l10n.commonNext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: AdminColors.surfaceAlt,
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(l10n.shelterColumnShelterId)),
          Expanded(flex: 3, child: Text(l10n.shelterColumnName)),
          Expanded(flex: 2, child: Text(l10n.shelterColumnZone)),
          Expanded(flex: 2, child: Text(l10n.shelterColumnStatus)),
          Expanded(flex: 3, child: Text(l10n.shelterColumnOccupancy)),
          Expanded(flex: 2, child: Text(l10n.shelterColumnContact)),
        ],
      ),
    );
  }

  Widget _buildTableBody(AppLocalizations l10n, List<ShelterRecord> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.sheltersEmptyFiltered,
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
        final shelter = items[index];
        final selected = _selected?.shelterId == shelter.shelterId;
        return Material(
          color: selected ? AdminColors.surfaceAlt : Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selected = shelter),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(shelter.shelterId)),
                  Expanded(flex: 3, child: Text(shelter.name)),
                  Expanded(flex: 2, child: Text(shelter.zone ?? '-')),
                  Expanded(
                    flex: 2,
                    child: Text(
                      shelter.status == 'Open'
                          ? l10n.shelterOpen
                          : shelter.status == 'Closed'
                              ? l10n.shelterClosed
                              : shelter.status,
                      style: TextStyle(
                        color: shelter.status == 'Open'
                            ? AdminColors.primary
                            : AdminColors.warning,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('${shelter.currentOccupancy}/${shelter.capacity}'),
                  ),
                  Expanded(flex: 2, child: Text(shelter.contact ?? '-')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailPane(AppLocalizations l10n) {
    final shelter = _selected;
    if (shelter == null) {
      return Card(
        child: Center(
          child: Text(
            l10n.sheltersSelectOne,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AdminColors.textMuted),
          ),
        ),
      );
    }

    final isSubmitting = _submittingShelterId == shelter.shelterId;
    final mapsKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shelter.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _kv('shelter_id', shelter.shelterId),
              _kv('status', shelter.status),
              _kv('zone', shelter.zone ?? '-'),
              _kv('capacity', '${shelter.capacity}'),
              _kv('current_occupancy', '${shelter.currentOccupancy}'),
              _kv('contact', shelter.contact ?? '-'),
              _kv('notes', shelter.notes ?? '-'),
              _kv('updated_at', _formatDateTime(shelter.updatedAt)),
              const SizedBox(height: 12),
              Text(
                l10n.locationPreview,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              _buildMapPreview(l10n, shelter, mapsKey),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: isSubmitting ? null : () => _toggleStatus(shelter),
                    child: Text(
                      shelter.status == 'Open'
                          ? l10n.shelterActionClose
                          : l10n.shelterActionOpen,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => _editCapacity(shelter),
                    child: Text(l10n.shelterActionUpdateCapacity),
                  ),
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => _editOccupancy(shelter),
                    child: Text(l10n.shelterActionUpdateOccupancy),
                  ),
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => _softDelete(shelter),
                    child: Text(l10n.shelterActionSoftDelete),
                  ),
                  if (isSubmitting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.shelterAuditNotice,
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

  Widget _buildMapPreview(
    AppLocalizations l10n,
    ShelterRecord shelter,
    String mapsKey,
  ) {
    final lat = shelter.latitude;
    final lng = shelter.longitude;
    if (lat == null || lng == null) {
      return _coordinatesCard(l10n.mapNoCoordinates);
    }

    if (mapsKey.isEmpty) {
      return _coordinatesCard(l10n.mapKeyMissing('$lat', '$lng'));
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/staticmap', {
      'center': '$lat,$lng',
      'zoom': '15',
      'size': '600x300',
      'markers': 'color:red|$lat,$lng',
      'key': mapsKey,
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Image.network(
          uri.toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _coordinatesCard(
              l10n.shelterMapLoadFailed('$lat', '$lng'),
            );
          },
        ),
      ),
    );
  }

  Widget _coordinatesCard(String text) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AdminColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AdminColors.border),
      ),
      alignment: Alignment.center,
      child: Text(text, textAlign: TextAlign.center),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              key,
              style: const TextStyle(color: AdminColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
