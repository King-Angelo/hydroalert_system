class AuthSignInResult {
  const AuthSignInResult._({
    required this.ok,
    this.adminUserId,
    this.errorCode,
  });

  const AuthSignInResult.success({required String adminUserId})
    : this._(ok: true, adminUserId: adminUserId);

  const AuthSignInResult.failure({required String errorCode})
    : this._(ok: false, errorCode: errorCode);

  final bool ok;
  final String? adminUserId;
  final String? errorCode;
}

abstract class AuthService {
  Future<AuthSignInResult> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<String?> sendPasswordReset({required String email});

  Future<void> signOut();

  Future<String?> getCurrentAdminUserId();

  /// Firebase ID token for `Authorization: Bearer` when calling the Dart Frog API.
  /// Mock implementations return `null`.
  Future<String?> getIdToken();
}
