/// Base URL for the Dart Frog API (no trailing slash).
///
/// ```bash
/// flutter run --dart-define=HYDROADMIN_API_BASE_URL=http://localhost:8080
/// ```
abstract final class AdminApiConfig {
  static const _envKey = 'HYDROADMIN_API_BASE_URL';

  static String get baseUrl {
    const v = String.fromEnvironment(_envKey, defaultValue: '');
    return v.trim().replaceAll(RegExp(r'/$'), '');
  }

  static bool get isConfigured => baseUrl.isNotEmpty;
}
