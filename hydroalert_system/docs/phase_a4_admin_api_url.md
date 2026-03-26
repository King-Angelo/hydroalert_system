# Phase A4 — `HYDROADMIN_API_BASE_URL` per environment

**What:** Set the **compile-time** define **`HYDROADMIN_API_BASE_URL`** for each admin build/run so it matches the **Dart Frog API** base URL for that world (no trailing slash).

**Why:** Already wired in **`apps/admin_app/lib/main.dart`** and **`AdminApiConfig`**:

- If **unset** → `AdminApiConfig.isConfigured == false` → **`ManualOverrideApiClient`** is **not** created → manual zone override and other HTTP features stay off.
- **`OperationsHealthPanel`** uses **`AdminApiConfig.baseUrl`** for **`GET /health/detailed`** when configured.

Firebase (Auth + Firestore) does **not** need this define; only **HTTP API** features do.

---

## Values (replace hosts with yours)

| Environment | Typical `HYDROADMIN_API_BASE_URL` |
|-------------|-------------------------------------|
| **Local dev** | `http://localhost:8080` (or whatever port **`dart_frog dev`** prints) |
| **Staging** | `https://your-api-staging.example.com` |
| **Production** | `https://your-api.example.com` |

Use **HTTPS** in staging/prod; match **`CORS_ALLOW_ORIGIN`** on the API to the **admin web origin** for that tier (**`docs/examples/backend-api.env.example`**).

---

## Commands

**Run (Chrome, local API):**

```bash
cd apps/admin_app
flutter run -d chrome \
  --dart-define=HYDRO_ENV=dev \
  --dart-define=HYDROADMIN_API_BASE_URL=http://localhost:8080
```

**Build web (staging example):**

```bash
cd apps/admin_app
flutter build web \
  --dart-define=HYDRO_ENV=staging \
  --dart-define=HYDROADMIN_API_BASE_URL=https://your-staging-api.example.com
```

**VS Code / Cursor:** **`hydroalert_system/.vscode/launch.json`** includes **“Chrome + local API”** and **“Firestore only”** configurations.

**PowerShell helper (repo root `hydroalert_system/scripts/`):** `run-admin-chrome-dev.ps1` runs the local-API line above.

---

## CI

Staging example workflow: **`docs/examples/build-admin-web-staging.workflow.yml`** passes **`HYDROADMIN_API_BASE_URL`** into **`flutter build web`**.

For production, mirror the same pattern with your **prod API** URL (prefer a **secret** or **variable** if the URL is sensitive or changes per branch).

---

## Related

- **`docs/environment_separation_p0.md`** — multi-env overview  
- **`apps/admin_app/lib/core/config/admin_api_config.dart`** — define key name and trimming  
- **`docs/phase_a5_smoke_firestore.md`** — after API URL works, smoke-test Firestore screens (Phase A5)  
