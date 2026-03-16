import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/admin_theme.dart';
import '../data/user_management_repository.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({
    super.key,
    required this.userManagementRepository,
    required this.adminUserId,
  });

  final UserManagementRepository userManagementRepository;
  final String adminUserId;

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  static const _pageSize = 20;
  static const _filters = <String>[
    'All',
    'Admin',
    'Official',
    'Resident',
    'Inactive',
  ];

  final Map<int, UserManagementPageResult> _pages = {};
  final List<DateTime?> _startCursors = [null];
  int _pageIndex = 0;
  String _filter = 'All';
  String _searchQuery = '';
  bool _loading = true;
  String? _error;
  String? _submittingUserId;
  ManagedUserRecord? _selectedUser;

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
      final result = await widget.userManagementRepository.fetchUsersPage(
        filter: _filter,
        searchQuery: _searchQuery,
        pageSize: _pageSize,
        startAfterUpdatedAt: _startCursors[pageIndex],
      );

      if (!mounted) return;
      setState(() {
        _pages[pageIndex] = result;
        if (_startCursors.length == pageIndex + 1) {
          _startCursors.add(result.nextCursorUpdatedAt);
        } else {
          _startCursors[pageIndex + 1] = result.nextCursorUpdatedAt;
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
      setState(() => _selectedUser = null);
      return;
    }

    final selectedId = _selectedUser?.userId;
    final stillVisible =
        selectedId != null && page.items.any((item) => item.userId == selectedId);
    if (!stillVisible) {
      setState(() => _selectedUser = page.items.first);
    }
  }

  void _resetPagesAndReload() {
    setState(() {
      _pageIndex = 0;
      _pages.clear();
      _startCursors
        ..clear()
        ..add(null);
      _selectedUser = null;
      _error = null;
    });
    _loadPage(pageIndex: 0, force: true);
  }

  Future<void> _goNextPage() async {
    final current = _pages[_pageIndex];
    if (current == null || !current.hasNextPage) return;
    final nextIndex = _pageIndex + 1;
    setState(() => _pageIndex = nextIndex);
    await _loadPage(pageIndex: nextIndex);
  }

  void _goPreviousPage() {
    if (_pageIndex == 0) return;
    setState(() => _pageIndex -= 1);
    _syncSelectionWithCurrentPage();
  }

  Future<void> _updateRole(String nextRole) async {
    final user = _selectedUser;
    if (user == null || user.userType == 'admin') return;
    if (user.userType == nextRole) return;

    setState(() => _submittingUserId = user.userId);
    try {
      await widget.userManagementRepository.updateUserRole(
        targetUserId: user.userId,
        nextRole: nextRole,
        adminId: widget.adminUserId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role updated for ${user.userId}.')),
      );
      _pages.remove(_pageIndex);
      await _loadPage(pageIndex: _pageIndex, force: true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingUserId = null);
      }
    }
  }

  Future<void> _toggleActive() async {
    final user = _selectedUser;
    if (user == null || user.userType == 'admin') return;

    setState(() => _submittingUserId = user.userId);
    try {
      await widget.userManagementRepository.setUserActiveState(
        targetUserId: user.userId,
        isActive: !user.isActive,
        adminId: widget.adminUserId,
      );
      if (!mounted) return;
      final action = user.isActive ? 'deactivated' : 'activated';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${user.userId} $action.')),
      );
      _pages.remove(_pageIndex);
      await _loadPage(pageIndex: _pageIndex, force: true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user state: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingUserId = null);
      }
    }
  }

  Future<void> _softDelete() async {
    final user = _selectedUser;
    if (user == null || user.userType == 'admin') return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soft Delete User'),
        content: Text(
          'Set ${user.userId} as inactive and store deleted_at timestamp?',
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
    if (shouldDelete != true) return;

    setState(() => _submittingUserId = user.userId);
    try {
      await widget.userManagementRepository.softDeleteUser(
        targetUserId: user.userId,
        adminId: widget.adminUserId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${user.userId} soft deleted.')),
      );
      _pages.remove(_pageIndex);
      await _loadPage(pageIndex: _pageIndex, force: true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Soft delete failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingUserId = null);
      }
    }
  }

  Future<void> _copyTokens() async {
    final user = _selectedUser;
    if (user == null || user.deviceTokens.isEmpty) return;
    final content = user.deviceTokens.join('\n');
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${user.deviceTokens.length} token(s).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_pageIndex];
    final items = page?.items ?? const <ManagedUserRecord>[];

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 1250;
        final listPane = _buildListPane(items: items, page: page);
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
  }

  Widget _buildListPane({
    required List<ManagedUserRecord> items,
    required UserManagementPageResult? page,
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
              children: _filters.map((filter) {
                final selected = filter == _filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) {
                    if (_filter == filter) return;
                    setState(() => _filter = filter);
                    _resetPagesAndReload();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search by email or user_id',
              ),
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                _resetPagesAndReload();
              },
            ),
            const SizedBox(height: 10),
            _buildTableHeader(),
            const Divider(color: AdminColors.border, height: 1),
            Expanded(child: _buildTableBody(items: items)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Page ${_pageIndex + 1}'),
                const Spacer(),
                OutlinedButton(
                  onPressed: _pageIndex > 0 && !_loading ? _goPreviousPage : null,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: !_loading && (page?.hasNextPage ?? false)
                      ? _goNextPage
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
          Expanded(flex: 3, child: Text('user_id')),
          Expanded(flex: 4, child: Text('email')),
          Expanded(flex: 2, child: Text('user_type')),
          Expanded(flex: 2, child: Text('active')),
          Expanded(flex: 2, child: Text('tokens')),
        ],
      ),
    );
  }

  Widget _buildTableBody({required List<ManagedUserRecord> items}) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Unable to load users.\n$_error',
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
          'No users found.',
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
        final user = items[index];
        final selected = _selectedUser?.userId == user.userId;
        return Material(
          color: selected ? AdminColors.surfaceAlt : Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selectedUser = user),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(user.userId)),
                  Expanded(flex: 4, child: Text(user.email)),
                  Expanded(flex: 2, child: Text(user.userType)),
                  Expanded(
                    flex: 2,
                    child: Text(
                      user.isActive ? 'true' : 'false',
                      style: TextStyle(
                        color: user.isActive
                            ? AdminColors.primary
                            : AdminColors.danger,
                      ),
                    ),
                  ),
                  Expanded(flex: 2, child: Text('${user.deviceTokens.length}')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailPane() {
    final user = _selectedUser;
    if (user == null) {
      return Card(
        child: Center(
          child: Text(
            'Select a user to inspect details.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AdminColors.textMuted),
          ),
        ),
      );
    }

    final mapsKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    final canManage = user.userType != 'admin';
    final isSubmitting = _submittingUserId == user.userId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.userId, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _kv('email', user.email),
              _kv('user_type', user.userType),
              _kv('is_active', user.isActive.toString()),
              _kv('token_count', '${user.deviceTokens.length}'),
              _kv('created_at', _formatDateTime(user.createdAt)),
              _kv('updated_at', _formatDateTime(user.updatedAt)),
              _kv('deleted_at', user.deletedAt == null ? '-' : _formatDateTime(user.deletedAt!)),
              _kv('barangay', user.barangay ?? '-'),
              const SizedBox(height: 12),
              Text('Location Preview', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              _buildMapPreview(user, mapsKey),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: user.deviceTokens.isEmpty ? null : _copyTokens,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy tokens'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!canManage)
                Text(
                  'Admin accounts are protected from role/state changes.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AdminColors.warning),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  DropdownButton<String>(
                    value: user.userType == 'official' || user.userType == 'resident'
                        ? user.userType
                        : null,
                    hint: const Text('Change role'),
                    items: const [
                      DropdownMenuItem(
                        value: 'official',
                        child: Text('official'),
                      ),
                      DropdownMenuItem(
                        value: 'resident',
                        child: Text('resident'),
                      ),
                    ],
                    onChanged: !canManage || isSubmitting
                        ? null
                        : (next) {
                            if (next == null) return;
                            _updateRole(next);
                          },
                  ),
                  FilledButton(
                    onPressed: !canManage || isSubmitting ? null : _toggleActive,
                    child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                  ),
                  OutlinedButton(
                    onPressed: !canManage || isSubmitting ? null : _softDelete,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview(ManagedUserRecord user, String mapsKey) {
    final lat = user.latitude;
    final lng = user.longitude;
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
            return _coordinatesCard(
              'Map failed to load.\nCoordinates: $lat, $lng',
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

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day $hour:$minute';
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
