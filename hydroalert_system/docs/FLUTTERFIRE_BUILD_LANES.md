# FlutterFire: one Firebase project per build lane

The admin app needs **`DefaultFirebaseOptions`** that match the **Firebase project** for that deploy (dev / staging / production). This doc describes how to keep **production** (and optionally staging) options **out of casual git commits** while keeping **PR CI** green.

---

## 1. What is checked in today

| File | Role |
|------|------|
| `apps/admin_app/lib/firebase_options_dev.dart` | **Development** project (`hydroalert-dev`). Safe to commit. |
| `apps/admin_app/lib/firebase_options.dart` | **Barrel** that `export`s `firebase_options_dev.dart` for local dev and `flutter analyze` on PRs. |

`main.dart` continues to import **`firebase_options.dart`** only.

**Initialization:** The admin app calls **`Firebase.initializeApp`** with **`DefaultFirebaseOptions.currentPlatform`** on every platform. If the checked-in options do not include that platform (e.g. Windows/Linux), **`UnsupportedError`** is caught and the app runs with **mock** repositories—**web** (and **Android** once configured in `firebase_options_dev.dart`) use real Firebase.

---

## 2. Regenerate **dev** options

From `hydroalert_system`:

```bash
cd apps/admin_app
firebase use dev   # or: firebase use <your-dev-project-id>
dart pub global activate flutterfire_cli
flutterfire configure --project=<dev-project-id> --platforms=web --out=lib/firebase_options_dev.dart
```

Then restore **`firebase_options.dart`** to the small barrel file if FlutterFire overwrote it:

```dart
export 'firebase_options_dev.dart';
```

(Or run configure with an output path that only touches `firebase_options_dev.dart`.)

---

## 3. Staging / production lanes (do not commit prod)

### Option A — CI writes `firebase_options.dart` (recommended for prod)

1. On a secure machine, run **`flutterfire configure`** against the **staging** or **production** Firebase project and capture the generated **`lib/firebase_options.dart`** content (full file with `class DefaultFirebaseOptions`).
2. Store that content in a **secret** (e.g. GitHub Actions secret `ADMIN_FIREBASE_OPTIONS_STAGING_DART` or `..._PRODUCTION_DART`).
3. In the deploy workflow, **before** `flutter build web`:

   ```bash
   # Example: secret holds the entire Dart file contents
   echo "$ADMIN_FIREBASE_OPTIONS_STAGING_DART" > apps/admin_app/lib/firebase_options.dart
   ```

4. Build with the same **`--dart-define`** values you already use (`HYDRO_ENV`, `HYDROADMIN_API_BASE_URL`).
5. **Do not** commit the generated `firebase_options.dart` from that job; artifacts are the **build output** only.

The **repository** keeps the dev barrel + `firebase_options_dev.dart`; production text never lands on `main`.

### Option B — Local staging build (optional)

1. Generate **`firebase_options_staging.dart`** with FlutterFire (output to a **gitignored** path — see `.gitignore`).
2. Temporarily replace **`firebase_options.dart`** with:

   ```dart
   export 'firebase_options_staging.dart';
   ```

3. Build; **do not commit** if your policy forbids staging keys in git (or commit staging only if your team accepts that risk).

### Gitignored filenames (optional local outputs)

See root **`.gitignore`** for:

- `apps/admin_app/lib/firebase_options.staging.dart`
- `apps/admin_app/lib/firebase_options.production.dart`

Use these names for FlutterFire `--out=` if you want local files without polluting `git status`.

---

## 4. CI policy: no production project ID in tracked options

Workflow **Firebase options policy** reads **`.firebaserc`** → `projects.production` and fails if that project ID appears in any **tracked** `apps/admin_app/lib/firebase_options*.dart`.

If your production Firebase project ID changes, update **`.firebaserc`** so the check stays accurate.

---

## 5. Example: manual staging web build

```bash
cd apps/admin_app
# After injecting the correct firebase_options.dart for staging:
flutter build web \
  --dart-define=HYDRO_ENV=staging \
  --dart-define=HYDROADMIN_API_BASE_URL=https://hydroalert-api-staging.onrender.com
```

---

## Related

- **`docs/environment_separation_p0.md`**
- **Repository root** **`.github/workflows/ci.yml`**
- Optional workflow template: **`docs/examples/build-admin-web-staging.workflow.yml`**
