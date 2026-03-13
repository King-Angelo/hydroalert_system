class MockAuthService {
  const MockAuthService();

  Future<bool> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return email.trim().isNotEmpty && password.trim().isNotEmpty;
  }
}