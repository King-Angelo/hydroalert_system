/// Google Maps API key for the situation map (compile-time).
///
/// **Web:** also add the Maps JavaScript API script to `web/index.html` with the
/// same key (see admin app README).
///
/// **Android:** set `GOOGLE_MAPS_API_KEY` in `android/local.properties`.
///
/// **iOS:** set `GMSApiKey` in `ios/Runner/Info.plist` (or Xcode build settings).
///
/// ```bash
/// flutter run --dart-define=HYDROADMIN_GOOGLE_MAPS_API_KEY=your_key
/// ```
abstract final class MapsConfig {
  static const _envKey = 'HYDROADMIN_GOOGLE_MAPS_API_KEY';

  static String get apiKey {
    const v = String.fromEnvironment(_envKey, defaultValue: '');
    return v.trim();
  }

  static bool get isConfigured => apiKey.isNotEmpty;
}
