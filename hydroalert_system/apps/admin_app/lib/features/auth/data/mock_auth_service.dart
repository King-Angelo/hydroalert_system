import 'auth_service.dart';

class MockAuthService implements AuthService {
  const MockAuthService();

  @override
  Stream<void> get sessionTerminated => const Stream.empty();

  @override
  Future<AuthSignInResult> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final ok = email.trim().isNotEmpty && password.trim().isNotEmpty;
    if (!ok) {
      return const AuthSignInResult.failure(errorCode: 'mock-invalid-input');
    }
    return const AuthSignInResult.success(adminUserId: 'admin_001');
  }

  @override
  Future<String?> sendPasswordReset({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'invalid-email';
    }
    return null;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<String?> getCurrentAdminUserId() async {
    return 'admin_001';
  }

  @override
  Future<String?> getIdToken() async => null;
}