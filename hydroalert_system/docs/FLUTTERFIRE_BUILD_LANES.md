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

### Option A — CI writes `firebase_options.dart` (recommended for staging / prod)

The **repository** workflow **[`.github/workflows/build-admin-web-staging.yml`](../../.github/workflows/build-admin-web-staging.yml)** (repo root) injects options from a secret, then runs `flutter build web`. Tracked **`firebase_options.dart`** stays a dev **barrel**; the job overwrites it only inside the runner.

#### One-time: generate the secret file for **staging** (`hydroalert-staging`)

On a trusted machine (with Flutter + Firebase CLI logged in):

```bash
cd hydroalert_system/apps/admin_app
dart pub global activate flutterfire_cli
flutterfire configure --project=hydroalert-staging --platforms=web --out=lib/firebase_options.staging.dart
```

Open **`lib/firebase_options.staging.dart`** — copy the **entire** file (from the first `//` or `import` through the last `}`). That string must define **`DefaultFirebaseOptions`** the same way a normal FlutterFire **`firebase_options.dart`** does.

That path is **gitignored** (see root **`.gitignore`**). Do **not** commit it; keep the content only in **GitHub Actions secrets**.

#### One-time: GitHub Actions secrets

Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:

| Name | Value |
|------|--------|
| **`ADMIN_FIREBASE_OPTIONS_STAGING_DART`** | Full pasted contents of the generated Dart file (multiline). |
| **`HYDROADMIN_API_BASE_URL_STAGING`** *(optional)* | e.g. `https://your-staging-api.onrender.com` (no trailing slash). |
| **`HYDROADMIN_GOOGLE_MAPS_API_KEY`** *(optional)* | Use the same browser key as in **`apps/admin_app/web/index.html`** locally. If omitted, staging builds keep the **static mock** Situation Map (`MapsConfig` stays empty). If set, CI rewrites the script `key=` in `index.html` and passes `--dart-define=HYDROADMIN_GOOGLE_MAPS_API_KEY=...`. In Google Cloud → API key restrictions, add referrer `https://hydroalert-staging.web.app/*` (and `http://localhost:*/*` for local). |

If you skip the URL secret, you must pass the same URL when you **Run workflow** as input **`api_base`**.

#### Run the build

GitHub → **Actions** → **Build admin web (staging)** → **Run workflow** → optional **api_base** → run.

Download artifact **`admin-web-staging`** (`build/web` contents). Deploy that folder to Firebase Hosting for **`hydroalert-staging`** (e.g. `firebase deploy --only hosting` with **`firebase use staging`** from **`hydroalert_system/`**).

#### Production

Use the same pattern with a **different** secret (e.g. `ADMIN_FIREBASE_OPTIONS_PRODUCTION_DART`) and a **separate** workflow or job — **do not** put production options in the staging secret.

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

## 5. Manual staging web build + Hosting deploy

**Prerequisite:** `firebase_options` must target **`hydroalert-staging`** for this build (Option B: generate `lib/firebase_options.staging.dart`, then temporarily set `lib/firebase_options.dart` to `export 'firebase_options.staging.dart';` — **do not commit**). Or use the **CI workflow** and download the artifact.

From **`hydroalert_system/`** (after `flutter build web`):

```bash
firebase use staging
cd apps/admin_app
flutter build web \
  --dart-define=HYDRO_ENV=staging \
  --dart-define=HYDROADMIN_API_BASE_URL=https://YOUR-STAGING-API.onrender.com
cd ../..
firebase deploy --only hosting
```

**PowerShell** (line continuation is `` ` ``):

```powershell
firebase use staging
cd apps/admin_app
flutter build web `
  --dart-define=HYDRO_ENV=staging `
  --dart-define=HYDROADMIN_API_BASE_URL=https://YOUR-STAGING-API.onrender.com
cd ../..
firebase deploy --only hosting
```

Root **`firebase.json`** maps Hosting **`public`** to **`apps/admin_app/build/web`** so deploy uses the Flutter output. Set **`CORS_ALLOW_ORIGIN`** on the **staging** Render API to your **Hosting** URL (e.g. `https://hydroalert-staging.web.app`).

---

## Related

- **`docs/environment_separation_p0.md`**
- **Repository root** **`.github/workflows/ci.yml`**
- Live workflow (repo root): **`build-admin-web-staging.yml`**
- Legacy copy snapshot: **`docs/examples/build-admin-web-staging.workflow.yml`** (prefer root workflow)
