import 'user_management_repository.dart';

class MockUserManagementRepository implements UserManagementRepository {
  const MockUserManagementRepository();

  static final List<ManagedUserRecord> _users = [
    ManagedUserRecord(
      userId: 'admin_001',
      email: 'admin@hydroalert.local',
      userType: 'admin',
      isActive: true,
      deviceTokens: const [],
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      latitude: 14.5995,
      longitude: 120.9842,
      barangay: 'Barangay 728',
    ),
    ManagedUserRecord(
      userId: 'official_001',
      email: 'official1@hydroalert.local',
      userType: 'official',
      isActive: true,
      deviceTokens: const ['fcm_token_official_1'],
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      latitude: 14.6001,
      longitude: 120.9851,
      barangay: 'Barangay 728',
    ),
    ManagedUserRecord(
      userId: 'resident_001',
      email: 'resident1@hydroalert.local',
      userType: 'resident',
      isActive: true,
      deviceTokens: const ['fcm_token_resident_1', 'fcm_token_resident_2'],
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      latitude: 14.6011,
      longitude: 120.9861,
      barangay: 'Barangay 728',
    ),
    ManagedUserRecord(
      userId: 'resident_099',
      email: 'resident99@hydroalert.local',
      userType: 'resident',
      isActive: false,
      deviceTokens: const ['fcm_token_resident_99'],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      latitude: 14.6021,
      longitude: 120.9871,
      barangay: 'Barangay 728',
      deletedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  Future<UserManagementPageResult> fetchUsersPage({
    required String filter,
    required String searchQuery,
    int pageSize = 20,
    DateTime? startAfterUpdatedAt,
  }) async {
    final query = searchQuery.trim().toLowerCase();
    var filtered = _users.where((user) {
      switch (filter) {
        case 'Admin':
          return user.userType == 'admin';
        case 'Official':
          return user.userType == 'official';
        case 'Resident':
          return user.userType == 'resident';
        case 'Inactive':
          return !user.isActive;
        case 'All':
        default:
          return true;
      }
    }).toList();

    if (query.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.userId.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    }

    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final pageSource = startAfterUpdatedAt == null
        ? filtered
        : filtered.where((u) => u.updatedAt.isBefore(startAfterUpdatedAt)).toList();
    final hasNext = pageSource.length > pageSize;
    final visible = pageSource.take(pageSize).toList();
    final nextCursor = hasNext && visible.isNotEmpty ? visible.last.updatedAt : null;

    return UserManagementPageResult(
      items: visible,
      hasNextPage: hasNext,
      nextCursorUpdatedAt: nextCursor,
    );
  }

  @override
  Future<void> updateUserRole({
    required String targetUserId,
    required String nextRole,
    required String adminId,
  }) async {
    final index = _users.indexWhere((user) => user.userId == targetUserId);
    if (index == -1) throw StateError('User not found: $targetUserId');
    final current = _users[index];
    if (current.userType == 'admin') {
      throw StateError('Admin accounts cannot be modified from this module.');
    }
    _users[index] = ManagedUserRecord(
      userId: current.userId,
      email: current.email,
      userType: nextRole,
      isActive: current.isActive,
      deviceTokens: current.deviceTokens,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      latitude: current.latitude,
      longitude: current.longitude,
      barangay: current.barangay,
      deletedAt: current.deletedAt,
    );
  }

  @override
  Future<void> setUserActiveState({
    required String targetUserId,
    required bool isActive,
    required String adminId,
  }) async {
    final index = _users.indexWhere((user) => user.userId == targetUserId);
    if (index == -1) throw StateError('User not found: $targetUserId');
    final current = _users[index];
    if (current.userType == 'admin') {
      throw StateError('Admin accounts cannot be modified from this module.');
    }
    _users[index] = ManagedUserRecord(
      userId: current.userId,
      email: current.email,
      userType: current.userType,
      isActive: isActive,
      deviceTokens: current.deviceTokens,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      latitude: current.latitude,
      longitude: current.longitude,
      barangay: current.barangay,
      deletedAt: isActive ? null : DateTime.now(),
    );
  }

  @override
  Future<void> softDeleteUser({
    required String targetUserId,
    required String adminId,
  }) async {
    await setUserActiveState(
      targetUserId: targetUserId,
      isActive: false,
      adminId: adminId,
    );
  }
}
