import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shelter ${shelter.shelterId} marked as $nextStatus.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status update failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingShelterId = null);
      }
    }
  }

  Future<void> _editCapacity(ShelterRecord shelter) async {
    final value = await _openNumberDialog(
      title: 'Update Capacity',
      label: 'capacity',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capacity updated for ${shelter.shelterId}.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capacity update failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingShelterId = null);
      }
    }
  }

  Future<void> _editOccupancy(ShelterRecord shelter) async {
    final value = await _openNumberDialog(
      title: 'Update Occupancy',
      label: 'current_occupancy',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Occupancy updated for ${shelter.shelterId}.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Occupancy update failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingShelterId = null);
      }
    }
  }

  Future<void> _softDelete(ShelterRecord shelter) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soft Delete Shelter'),
        content: Text(
          'Set ${shelter.shelterId} as inactive and preserve historical links/logs?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shelter ${shelter.shelterId} soft deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Soft delete failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingShelterId = null);
      }
    }
  }

  Future<int?> _openNumberDialog({
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
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final value = int.tryParse(controller.text.trim());
                    if (value == null || value < 0) {
                      setDialogState(() {
                        validationError = 'Enter a valid non-negative integer.';
                      });
                      return;
                    }
                    Navigator.of(context).pop(value);
                  },
                  child: const Text('Save'),
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
        if (snapshot.hasError) {
          return Card(
            child: Center(
              child: Text(
                'Unable to load shelters.\n${snapshot.error}',
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
            final listPane = _buildListPane(filtered, pageItems);
            final detailPane = _buildDetailPane();

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

  Widget _buildListPane(List<ShelterRecord> filtered, List<ShelterRecord> pageItems) {
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
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statusFilters
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
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
                    decoration: const InputDecoration(labelText: 'Zone'),
                    items: _zoneFilters
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
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
                    decoration: const InputDecoration(labelText: 'Occupancy Level'),
                    items: const [
                      DropdownMenuItem(
                        value: ShelterOccupancyFilter.all,
                        child: Text('All'),
                      ),
                      DropdownMenuItem(
                        value: ShelterOccupancyFilter.available,
                        child: Text('Available (<80%)'),
                      ),
                      DropdownMenuItem(
                        value: ShelterOccupancyFilter.nearCapacity,
                        child: Text('Near cap (80-99%)'),
                      ),
                      DropdownMenuItem(
                        value: ShelterOccupancyFilter.full,
                        child: Text('Full (100%)'),
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
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search by shelter name or contact',
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
                  child: const Text('Apply'),
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
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTableHeader(),
            const Divider(color: AdminColors.border, height: 1),
            Expanded(child: _buildTableBody(pageItems)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Page ${_pageIndex + 1} / ${_totalPages(filtered)}'),
                const SizedBox(width: 12),
                Text(
                  '${filtered.length} active shelters',
                  style: const TextStyle(color: AdminColors.textMuted, fontSize: 12),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _pageIndex > 0
                      ? () => setState(() => _pageIndex -= 1)
                      : null,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: (_pageIndex + 1) < _totalPages(filtered)
                      ? () => setState(() => _pageIndex += 1)
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

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: AdminColors.surfaceAlt,
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('shelter_id')),
          Expanded(flex: 3, child: Text('name')),
          Expanded(flex: 2, child: Text('zone')),
          Expanded(flex: 2, child: Text('status')),
          Expanded(flex: 3, child: Text('occupancy')),
          Expanded(flex: 2, child: Text('contact')),
        ],
      ),
    );
  }

  Widget _buildTableBody(List<ShelterRecord> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No shelters found for current filters.',
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
                      shelter.status,
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

  Widget _buildDetailPane() {
    final shelter = _selected;
    if (shelter == null) {
      return Card(
        child: Center(
          child: Text(
            'Select a shelter to inspect details.',
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
                'Location Preview',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              _buildMapPreview(shelter, mapsKey),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: isSubmitting ? null : () => _toggleStatus(shelter),
                    child: Text(shelter.status == 'Open' ? 'Close' : 'Open'),
                  ),
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => _editCapacity(shelter),
                    child: const Text('Update Capacity'),
                  ),
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => _editOccupancy(shelter),
                    child: const Text('Update Occupancy'),
                  ),
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => _softDelete(shelter),
                    child: const Text('Soft Delete'),
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
                'All changes are logged to System_Logs as immutable audit records.',
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

  Widget _buildMapPreview(ShelterRecord shelter, String mapsKey) {
    final lat = shelter.latitude;
    final lng = shelter.longitude;
    if (lat == null || lng == null) {
      return _coordinatesCard('No coordinates available');
    }

    if (mapsKey.isEmpty) {
      return _coordinatesCard('Google Maps key missing.\nCoordinates: $lat, $lng');
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
            return _coordinatesCard('Map failed to load.\nCoordinates: $lat, $lng');
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
