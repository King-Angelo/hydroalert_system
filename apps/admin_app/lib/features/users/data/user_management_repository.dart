class ManagedUserRecord {
  const ManagedUserRecord({
    required this.userId,
    required this.email,
    required this.userType,
    required this.isActive,
    required this.deviceTokens,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.barangay,
    this.deletedAt,
  });

  final String userId;
  final String email;
  final String userType;
  final bool isActive;
  final List<String> deviceTokens;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;
  final String? barangay;
  final DateTime? deletedAt;
}

class UserManagementPageResult {
  const UserManagementPageResult({
    required this.items,
    required this.hasNextPage,
    required this.nextCursorUpdatedAt,
  });

  final List<ManagedUserRecord> items;
  final bool hasNextPage;
  final DateTime? nextCursorUpdatedAt;
}

abstract class UserManagementRepository {
  Future<UserManagementPageResult> fetchUsersPage({
    required String filter,
    required String searchQuery,
    int pageSize = 20,
    DateTime? startAfterUpdatedAt,
  });

  Future<void> updateUserRole({
    required String targetUserId,
    required String nextRole,
    required String adminId,
  });

  Future<void> setUserActiveState({
    required String targetUserId,
    required bool isActive,
    required String adminId,
  });

  Future<void> softDeleteUser({
    required String targetUserId,
    required String adminId,
  });
}
