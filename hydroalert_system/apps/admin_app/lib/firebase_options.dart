// Picks Firebase Web options by compile-time [RuntimeEnvironment] (HYDRO_ENV).
//
// - `dev` (default): `hydroalert-dev` — see [firebase_options_dev.dart].
// - `staging`: `hydroalert-staging` — **must** match Render `FIREBASE_PROJECT_ID` and staging Hosting.
//
// **Build for staging Hosting:**
//   flutter build web --dart-define=HYDRO_ENV=staging --dart-define=HYDROADMIN_API_BASE_URL=...
//
// GitHub Actions **Build admin web (staging)** overwrites this file with a
// full FlutterFire-generated file from secrets (see FLUTTERFIRE_BUILD_LANES.md).
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import 'core/config/runtime_environment.dart';
import 'firebase_options_dev.dart' as dev;
import 'firebase_options_staging.dart' as staging;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (RuntimeEnvironment.current) {
      case HydroEnvironment.staging:
        return staging.DefaultFirebaseOptions.currentPlatform;
      case HydroEnvironment.dev:
        return dev.DefaultFirebaseOptions.currentPlatform;
      case HydroEnvironment.production:
        // Until production options are checked in or injected by CI, align with dev for local analyze.
        return dev.DefaultFirebaseOptions.currentPlatform;
    }
  }
}
