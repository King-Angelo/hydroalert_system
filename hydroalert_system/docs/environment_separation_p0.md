# Environment separation (P0)

HydroAlert uses **three logical environments**: **development**, **staging**, and **production**. Each must map to **separate Firebase/Google Cloud projects** (or strictly isolated resources) so data, auth users, and FCM never leak across tiers.

---

## 1. Firebase projects (strict separation)

| Environment   | Purpose | Firebase project (example ID) |
|---------------|---------|----------------------------------|
| **dev**       | Daily engineering, noisy data OK | `hydroalert-dev` (existing) |
| **staging**   | Pre-prod QA, prod-like config | Create e.g. `hydroalert-staging` |
| **production**| Live users & devices | Create e.g. `hydroalert-prod` |

**Rules**

- **Never** point staging or production clients at `hydroalert-dev`.
- **Never** reuse production **service account** JSON in dev laptops for anything except local prod-debug (prefer separate keys per project).
- **Firestore rules / indexes**: deploy the **same** `firestore.rules` and `firestore.indexes.json` to **each** project after `firebase use <alias>` (or CI per project).

**CLI aliases** are defined in **`.firebaserc`**. Replace placeholder IDs with your real Firebase project IDs, then:

```bash
cd hydroalert_system
firebase use dev          # default for local
firebase use staging
firebase deploy --only firestore:rules,firestore:indexes
firebase use production
firebase deploy --only firestore:rules,firestore:indexes
```

---

## 2. Config & secrets (per environment)

### Backend API (Dart Frog)

| Variable | dev | staging | production |
|----------|-----|---------|------------|
| `FIREBASE_PROJECT_ID` | dev project ID | staging ID | prod ID |
| `GOOGLE_APPLICATION_CREDENTIALS` | path to **dev** SA JSON (local) | Render/env secret | Render/env secret |
| `CORS_ALLOW_ORIGIN` | optional / localhost | staging admin URL | production admin URL |
| `FCM_ALERTS_ENABLED`, `FCM_DRY_RUN`, etc. | `FCM_DRY_RUN=true` OK | prod-like | production values |

- **Local:** keep SA JSON under `backend/api/config/` (folder is **gitignored**).
- **Render:** one **Web Service per environment** (e.g. `hydroalert-api-staging`, `hydroalert-api-prod`) with **different** env vars and **different** `FIREBASE_SERVICE_ACCOUNT_JSON`.

See **`docs/examples/backend-api.env.example`** for a full list.

### Admin app (Flutter web)

| Mechanism | Purpose |
|-----------|---------|
| `HYDRO_ENV` | `dev` / `staging` / `production` — label only (see `RuntimeEnvironment`); does **not** switch Firebase project by itself. |
| `HYDROADMIN_API_BASE_URL` | Must be the **API base URL for that environment** (no trailing slash). |
| **`firebase_options.dart`** | **Dev:** barrel exporting **`firebase_options_dev.dart`**. **Staging/prod:** regenerate per lane (CI secret or gitignored file) — **`docs/FLUTTERFIRE_BUILD_LANES.md`**. |

**Build examples**

```bash
# Development (local API + dev Firebase options file)
flutter run -d chrome \
  --dart-define=HYDRO_ENV=dev \
  --dart-define=HYDROADMIN_API_BASE_URL=http://localhost:8080

# Staging
flutter build web \
  --dart-define=HYDRO_ENV=staging \
  --dart-define=HYDROADMIN_API_BASE_URL=https://hydroalert-api-staging.onrender.com
```

**P0 expectation:** you maintain **separate** `firebase_options.dart` **sources** per project (regenerate when switching projects) or use CI that injects the correct file per job — **do not** commit production keys.

### Firmware / ESP32

- One `secrets.h` per device class; **never** use production Web API keys in shared lab firmware images stored in repo (use dev/staging keys for templates).

---

## 3. Release gates (P0)

Use **[RELEASE_GATE_CHECKLIST.md](RELEASE_GATE_CHECKLIST.md)** before promoting **staging → production**.

**Automation (P0):** GitHub Actions **`.github/workflows/ci.yml`** runs `dart analyze` on the backend, `dart test` on `shared_models`, `flutter analyze` on `admin_app`, and a **Firebase options policy** job on PRs — a minimum gate; it does **not** deploy.

**Branch protection:** Require those checks on **`main`** — steps in **[`docs/GITHUB_BRANCH_PROTECTION.md`](GITHUB_BRANCH_PROTECTION.md)**.

**Render / hosting:** Per-environment services and env vars — **[`docs/RENDER_PER_ENVIRONMENT.md`](RENDER_PER_ENVIRONMENT.md)**.

**Admin FlutterFire:** Per-lane regeneration; keep prod options out of git — **[`docs/FLUTTERFIRE_BUILD_LANES.md`](FLUTTERFIRE_BUILD_LANES.md)**.

**Future (P1+):** staging auto-deploy on `main`, manual approval gate for production deploy, secret scanning.

---

## 4. Quick reference

| Artifact | Location |
|----------|----------|
| Firebase project aliases | `hydroalert_system/.firebaserc` |
| Firestore rules / indexes | `firestore.rules`, `firestore.indexes.json` |
| Backend env template | `docs/examples/backend-api.env.example` |
| Render notes | `backend/api/DEPLOY_RENDER.md` |
| PR CI (analyze / test) | `.github/workflows/ci.yml` |
| Branch protection how-to | `docs/GITHUB_BRANCH_PROTECTION.md` |
| Render: one service per tier | `docs/RENDER_PER_ENVIRONMENT.md` |
| FlutterFire build lanes | `docs/FLUTTERFIRE_BUILD_LANES.md` |

---

## 5. Creating staging / production projects

1. Firebase Console → **Add project** → name clearly (`hydroalert-staging`, etc.).
2. Enable **Firestore**, **Authentication**, **FCM** as in dev.
3. Register **Web app** (and others) → run **FlutterFire** for admin against **that** project.
4. Deploy **rules + indexes** to the new project.
5. Create **service account** → download JSON → store in secret manager / Render, **not** in git.
