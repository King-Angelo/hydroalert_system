# Admin API v1 — smoke tool (Phase 3)

**Purpose:** Cheap verification that **`GET /health/detailed`** and privileged **`POST /v1/...`** routes are deployed, behind **Bearer** auth, and return expected status codes **without** needing a full integration test harness (emulator + seeded data).

**Script:** `backend/api/tool/v1_admin_route_smoke.dart`  
**Related:** [admin_firestore_api_alignment.md](admin_firestore_api_alignment.md), [qa_reliability_p1.md](qa_reliability_p1.md), [RENDER_PER_ENVIRONMENT.md](RENDER_PER_ENVIRONMENT.md).

---

## Tier 1 — No secrets (CI-friendly if API URL is reachable)

- `GET /health/detailed` → **200**
- Each migrated route (**reports, users, shelters**) → **POST** without `Authorization` → **401**
- `POST /v1/alerts/manual-override` without auth → **401** only (no authenticated call here — success could send FCM)

**Env:**

| Variable | Default | Meaning |
|----------|---------|---------|
| `SMOKE_API_BASE` | `http://localhost:8080` | API origin, no trailing slash |

**Run** (from `hydroalert_system/backend/api`):

```bash
dart pub get
SMOKE_API_BASE=https://your-staging-api.onrender.com dart run tool/v1_admin_route_smoke.dart
```

**PowerShell** (same folder):

```powershell
dart pub get
$env:SMOKE_API_BASE = "https://your-staging-api.onrender.com"
dart run tool/v1_admin_route_smoke.dart
```

**CI:** repository root **Actions** → **API smoke (tier 1)** → **Run workflow** → paste API URL (see root `.github/workflows/api-smoke-tier1.yml`).

---

## Tier 2 — Firebase admin ID token (staging / manual)

Uses synthetic document IDs; expects **404** (not found), which proves the **token was verified** and the handler ran against Firestore.

**Requirements:**

- `SMOKE_FIREBASE_ID_TOKEN` — a valid **Firebase ID token** for a user who is **`user_type: admin`** and **`is_active: true`** in `Users/{uid}` for the **same Firebase project** the API uses.
- Do **not** commit the token; rotate if leaked.

**How to obtain a short-lived token (example):** sign in to **admin web** on the target tier, open browser DevTools → **Network**, trigger any API call, copy the **`Authorization: Bearer …`** value (or use Firebase client SDK `getIdToken()` in a one-off snippet).

**Run:**

```bash
SMOKE_API_BASE=https://your-staging-api.onrender.com SMOKE_FIREBASE_ID_TOKEN=eyJ... dart run tool/v1_admin_route_smoke.dart
```

**PowerShell:**

```powershell
$env:SMOKE_API_BASE = "https://your-staging-api.onrender.com"
$env:SMOKE_FIREBASE_ID_TOKEN = "eyJ..."
dart run tool/v1_admin_route_smoke.dart
```

If tier 2 fails with **403**, the token is not an **active admin** for that project.

---

## What this does *not* replace

- **End-to-end business validation** (real `reportId`, shelter capacity rules, etc.) — still do a **manual** pass from staging admin UI or dedicated QA data.
- **CORS** from a browser — this tool uses `dart:io` HTTP; align **`CORS_ALLOW_ORIGIN`** with [environment_separation_p0.md](environment_separation_p0.md) and test from the real **Hosting** origin separately.

---

## Release checklist

After deploy to **staging**, optionally run tier 1 against the staging API URL before promoting admin Hosting builds. See [RELEASE_GATE_CHECKLIST.md](RELEASE_GATE_CHECKLIST.md) section B.
