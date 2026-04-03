# QA & Reliability (P1)

HydroAlert is **safety-adjacent**: barangay staff and responders depend on **timely, accurate** information. This document defines **what we automate in CI**, what we run **manually / on staging**, and how we practice **disaster drills**—without requiring paid load-testing SaaS.

---

## 1. Test pyramid (this repo)

| Layer | What | Where |
|-------|------|--------|
| **Unit** | Shared models, manual-override **request validation**, process clock, admin HTTP client behavior | `dart test` / `flutter test` in CI |
| **Service / API** | Full Dart Frog routes need a running server + Firebase; not in default CI | Staging or local `dart_frog dev` |
| **E2E (sensor → admin → alert)** | Physical or emulated device → Firestore → (future Cloud Function) → FCM → device | **Staging + checklist** (below) |
| **Load** | Concurrent `GET /health` (or `/health/detailed`) | `backend/api/tool/qa_load_probe.dart` |
| **V1 smoke (staging / local)** | Health + privileged **`POST /v1/...`** return **401** without token; optional **404** probes with admin Bearer | `backend/api/tool/v1_admin_route_smoke.dart` — [admin_api_v1_smoke.md](admin_api_v1_smoke.md) |
| **Network failure** | `ClientException`, HTTP errors on admin API client | `apps/admin_app/test/manual_override_api_client_test.dart` |

---

## 2. Commands

**Backend (from `hydroalert_system/backend/api`):**

```bash
dart pub get
dart analyze
dart test
```

**Admin app (from `hydroalert_system/apps/admin_app`):**

```bash
flutter pub get
flutter analyze
flutter test
```

**Load probe** (API must be reachable):

```bash
cd backend/api
dart run tool/qa_load_probe.dart
```

Optional env vars: `QA_API_BASE`, `QA_LOAD_PATH`, `QA_LOAD_CONCURRENCY`, `QA_LOAD_ROUNDS` (see script header).

**V1 admin route smoke** (API must be reachable; optional admin ID token):

```bash
cd backend/api
SMOKE_API_BASE=https://your-api.example.com dart run tool/v1_admin_route_smoke.dart
```

See [admin_api_v1_smoke.md](admin_api_v1_smoke.md) for `SMOKE_FIREBASE_ID_TOKEN` (tier 2).

---

## 3. End-to-end path (sensor → backend → admin → alert)

**Target architecture:** ESP32 (or gateway) writes **`IoT_Devices`** / readings → **Cloud Function** (or batch job) evaluates thresholds → **FCM** → resident/official devices. **Admin** monitors **IoT**, **System_Logs**, and may trigger **manual override** via the **Dart Frog API**.

**Automated today:** validation of manual-override JSON; admin client error handling; dashboard **Operations** strip (API + sensor staleness).

**Staging E2E checklist (run periodically):**

1. **Sensor / simulator** — write a test reading + `last_seen_at` to **`IoT_Devices`** (or use firmware against **dev/staging** project).
2. **Admin** — confirm device appears and is **not stale** in **IoT devices** + **Operations & health**.
3. **Manual override** (or automated alert when Functions exist) — send alert for a zone with a **test user** that has **`device_tokens`**.
4. **Verify** — `System_Logs` entry, `push` map, and device receives notification (or `FCM_DRY_RUN` validation only).
5. **Timing** — compare timestamps against **≤ 30 s** goal (see [observability_p1.md](observability_p1.md)).

Record results in **[disaster_drill_checklist.md](disaster_drill_checklist.md)** or your ops log.

---

## 4. Load testing (free tier)

- Use **`qa_load_probe.dart`** against **staging** during a maintenance window.
- **Do not** hammer **production** on Spark/Render free tiers; keep concurrency modest (e.g. 5–20).
- For heavier needs later, consider **k6** or **Locust** with the same env base URL—optional, not required for P1.

---

## 5. Network failure & degradation

| Scenario | Expectation |
|----------|-------------|
| API unreachable | Admin manual override throws; UI should surface error (verify manually once). |
| `ClientException` | Covered by unit test on `ManualOverrideApiClient`. |
| Intermittent 5xx | Retries are **not** implemented in P1 client; document operational retry (user taps again). |
| Render cold start | First request after sleep may exceed 30s **to API**; factor into drills. |

---

## 6. Disaster drill

Use **[disaster_drill_checklist.md](disaster_drill_checklist.md)** for a repeatable tabletop / live drill: partial connectivity, bad sensor data, failed FCM, and post-incident log export.

---

## 7. Related docs

- [observability_p1.md](observability_p1.md) — metrics, logs, health endpoints  
- [notifications_fcm_p0.md](notifications_fcm_p0.md) — FCM behavior  
- [environment_separation_p0.md](environment_separation_p0.md) — always drill on **staging** first  
