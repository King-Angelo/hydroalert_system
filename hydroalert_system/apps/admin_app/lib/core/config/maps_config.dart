import 'package:flutter/foundation.dart';

import 'maps_js_available_stub.dart'
    if (dart.library.html) 'maps_js_available_web.dart'
    if (dart.library.js_interop) 'maps_js_available_web.dart';

/// Google Maps API key for the situation map (compile-time).
///
/// **Web:** add the Maps JavaScript API script to `web/index.html` with a browser key.
/// If the script loads successfully, the situation map uses the live widget even when
/// `HYDROADMIN_GOOGLE_MAPS_API_KEY` was not passed at build time (e.g. some CI builds).
/// Passing `--dart-define=HYDROADMIN_GOOGLE_MAPS_API_KEY=...` is still recommended so
/// the native map stack and web stay aligned.
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

  static bool get isConfigured =>
      apiKey.isNotEmpty || (kIsWeb && isGoogleMapsScriptLoaded());
}
