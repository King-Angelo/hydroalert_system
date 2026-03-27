# HydroAlert admin app

## Environment (dev / staging / production)

- **`HYDRO_ENV`** — compile-time label: `--dart-define=HYDRO_ENV=dev|staging|production` (see `lib/core/config/runtime_environment.dart`). Shown in debug logs on startup.
- **`HYDROADMIN_API_BASE_URL`** — backend API base URL for manual override and related calls (no trailing slash).
- **`HYDROADMIN_GOOGLE_MAPS_API_KEY`** — optional; when set (and the platform supports `google_maps_flutter`), the dashboard **Situation Map** uses Google Maps with markers from **`IoT_Devices.location`** (`lat` / `lng` or `latitude` / `longitude`). When unset, the static PNG mock is used (no key required).
  - **Web:** add the Maps JavaScript API script to **`web/index.html`** with the same key (see comment in that file).
  - **Android:** set **`GOOGLE_MAPS_API_KEY`** in **`android/local.properties`** (passed into the manifest as `com.google.android.geo.API_KEY`).
  - **iOS:** set **`GMSApiKey`** in **`ios/Runner/Info.plist`** (or via Xcode build settings). Run **`pod install`** after adding `google_maps_flutter`.
- **`firebase_options.dart` / `firebase_options_dev.dart`** — dev project is in **`firebase_options_dev.dart`**; the barrel **`firebase_options.dart`** exports it. Staging/prod: inject in CI or use gitignored files — see **`docs/FLUTTERFIRE_BUILD_LANES.md`**.

See repo **[`docs/environment_separation_p0.md`](../../docs/environment_separation_p0.md)**.

**Hardening (P1):** **[`docs/admin_app_hardening_p1.md`](../../docs/admin_app_hardening_p1.md)** — localization, session re-auth, validation, accessibility.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
