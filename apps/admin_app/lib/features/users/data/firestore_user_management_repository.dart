import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_management_repository.dart';

class FirestoreUserManagementRepository implements UserManagementRepository {
  FirestoreUserManagementRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _usersCollection = 'Users';
  static const _logsCollection = 'System_Logs';

  @override
  Future<UserManagementPageResult> fetchUsersPage({
    required String filter,
    required String searchQuery,
    int pageSize = 20,
    DateTime? startAfterUpdatedAt,
  }) async {
    final queryText = searchQuery.trim().toLowerCase();

    Query<Map<String, dynamic>> query = _firestore
        .collection(_usersCollection)
        .orderBy('updated_at', descending: true);

    if (startAfterUpdatedAt != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterUpdatedAt)]);
    }

    // v1: avoid composite indexes by filtering in memory.
    final needsClientFiltering = filter != 'All' || queryText.isNotEmpty;
    final fetchLimit = needsClientFiltering ? 200 : pageSize + 1;
    final snapshot = await query.limit(fetchLimit).get();
    var users = snapshot.docs
        .map((doc) => _mapUserDoc(doc.id, doc.data()))
        .toList();

    users = users.where((user) => _matchesFilter(user, filter)).toList();

    if (queryText.isNotEmpty) {
      users = users.where((user) {
        final inId = user.userId.toLowerCase().contains(queryText);
        final inEmail = user.email.toLowerCase().contains(queryText);
        return inId || inEmail;
      }).toList();
    }

    users.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final hasNext = users.length > pageSize;
    final visible = users.take(pageSize).toList();
    final nextCursor = hasNext && visible.isNotEmpty ? visible.last.updatedAt : null;

    return UserManagementPageResult(
      items: visible,
      hasNextPage: hasNext,
      nextCursorUpdatedAt: nextCursor,
    );
  }

  bool _matchesFilter(ManagedUserRecord user, String filter) {
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
  }

  @override
  Future<void> updateUserRole({
    required String targetUserId,
    required String nextRole,
    required String adminId,
  }) async {
    final normalizedRole = nextRole.trim().toLowerCase();
    if (normalizedRole != 'official' && normalizedRole != 'resident') {
      throw ArgumentError('Role must be either official or resident.');
    }

    final userRef = _firestore.collection(_usersCollection).doc(targetUserId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw StateError('User not found: $targetUserId');
      }

      final data = snapshot.data()!;
      final currentRole = (data['user_type'] as String?)?.trim().toLowerCase() ?? '';
      if (currentRole == 'admin') {
        throw StateError('Admin accounts cannot be modified from this module.');
      }
      if (currentRole == normalizedRole) return;

      transaction.update(userRef, {
        'user_type': normalizedRole,
        'updated_at': FieldValue.serverTimestamp(),
      });

      _writeAuditLog(
        transaction: transaction,
        adminId: adminId,
        targetUserId: targetUserId,
        action: 'role_change',
        before: {'user_type': currentRole},
        after: {'user_type': normalizedRole},
        notes: 'Role updated from $currentRole to $normalizedRole',
      );
    });
  }

  @override
  Future<void> setUserActiveState({
    required String targetUserId,
    required bool isActive,
    required String adminId,
  }) async {
    final userRef = _firestore.collection(_usersCollection).doc(targetUserId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw StateError('User not found: $targetUserId');
      }

      final data = snapshot.data()!;
      final currentRole = (data['user_type'] as String?)?.trim().toLowerCase() ?? '';
      if (currentRole == 'admin') {
        throw StateError('Admin accounts cannot be modified from this module.');
      }

      final currentActive = data['is_active'] == true;
      if (currentActive == isActive) return;

      transaction.update(userRef, {
        'is_active': isActive,
        'updated_at': FieldValue.serverTimestamp(),
        if (!isActive) 'deleted_at': FieldValue.serverTimestamp(),
        if (isActive) 'deleted_at': FieldValue.delete(),
      });

      final action = isActive ? 'activate_user' : 'deactivate_user';
      _writeAuditLog(
        transaction: transaction,
        adminId: adminId,
        targetUserId: targetUserId,
        action: action,
        before: {'is_active': currentActive},
        after: {'is_active': isActive},
        notes: 'User ${isActive ? 'activated' : 'deactivated'}',
      );
    });
  }

  @override
  Future<void> softDeleteUser({
    required String targetUserId,
    required String adminId,
  }) async {
    final userRef = _firestore.collection(_usersCollection).doc(targetUserId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw StateError('User not found: $targetUserId');
      }

      final data = snapshot.data()!;
      final currentRole = (data['user_type'] as String?)?.trim().toLowerCase() ?? '';
      if (currentRole == 'admin') {
        throw StateError('Admin accounts cannot be modified from this module.');
      }

      transaction.update(userRef, {
        'is_active': false,
        'deleted_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      _writeAuditLog(
        transaction: transaction,
        adminId: adminId,
        targetUserId: targetUserId,
        action: 'soft_delete_user',
        before: {'is_active': data['is_active'] == true},
        after: {'is_active': false},
        notes: 'Soft delete requested by admin.',
      );
    });
  }

  void _writeAuditLog({
    required Transaction transaction,
    required String adminId,
    required String targetUserId,
    required String action,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
    required String notes,
  }) {
    final logRef = _firestore.collection(_logsCollection).doc();
    transaction.set(logRef, {
      'type': 'user_management_action',
      'admin_id': adminId,
      'target_user_id': targetUserId,
      'action': action,
      'before': before,
      'after': after,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  ManagedUserRecord _mapUserDoc(String id, Map<String, dynamic> data) {
    final email = (data['email'] as String?)?.trim();
    final userType = (data['user_type'] as String?)?.trim().toLowerCase();
    final isActive = data['is_active'] == true;
    final location = data['location'];
    final locationMap = location is Map<String, dynamic> ? location : null;
    final tokensRaw = data['device_tokens'];
    final tokens = tokensRaw is List
        ? tokensRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final createdAt = _readTimestamp(data['created_at']) ?? DateTime.now();
    final updatedAt =
        _readTimestamp(data['updated_at']) ?? _readTimestamp(data['created_at']) ?? DateTime.now();
    final deletedAt = _readTimestamp(data['deleted_at']);

    return ManagedUserRecord(
      userId: id,
      email: (email == null || email.isEmpty) ? 'unknown@user.local' : email,
      userType: (userType == null || userType.isEmpty) ? 'resident' : userType,
      isActive: isActive,
      deviceTokens: tokens,
      createdAt: createdAt,
      updatedAt: updatedAt,
      latitude: _toDouble(locationMap?['lat']),
      longitude: _toDouble(locationMap?['lng']),
      barangay: (locationMap?['barangay'] as String?)?.trim(),
      deletedAt: deletedAt,
    );
  }

  DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
