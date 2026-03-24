# Observability (P1) — Firebase **Spark (free)** & host logs

This document ties HydroAlert’s **prototype / internal validation** goals to concrete tooling: **barangay officials & responders** use **verified incident logs** for coordination; **developers** watch **reliability, security, and compatibility**—on **Firebase free tier (Spark)** and **free host logging**, without paid Google Cloud logging products.

---

## 1–2. Firebase free tier (Spark)

Use what Spark includes: **Firestore** (audit + IoT state), **Authentication**, **FCM**, **Firebase Analytics**, **Crashlytics** (mobile/desktop builds). Stay within Spark quotas; upgrade only if you outgrow them.

The **Dart Frog API** runs on **Render** (or similar): it is **not** billed as “GCP” in your Firebase project; keep secrets and env vars on the host.

---

## 3. Centralized logs — audience & retention

| Audience | What they use |
|----------|----------------|
| **Barangay officials & emergency responders** | **Verified** workflows: `Incident_Reports`, `System_Logs`, shelters, operational Firestore data—not raw server stdout. |
| **Developers / maintenance** | **API:** JSON lines on **stdout** (`http_request`, `http_error`, `alert_manual_override`). **Apps:** **Crashlytics** (non-web admin), **Analytics** (web + mobile). **Firestore:** schema-backed audit (`System_Logs`). |

**Retention:** Requirements call for **post-disaster analysis** (response times, performance) but not a fixed day count in-product. Practice:

- Follow **`database_operations.md`** for `System_Logs` retention / cron.
- For major events, **export** or snapshot logs from your **host** (Render logs) and Firebase Console as needed.

---

## 4. “Queue” latency (serverless, not Redis)

There is **no Redis queue**. The intended pattern is **async serverless work**: e.g. **Firestore write** (sensor / gateway) → **Cloud Function** (or equivalent) runs **alert logic**.

**Metric — alert processing time:** from **threshold breached** until **alert logic completes** (define whether that includes FCM send or stops at “enqueue/dispatch”).

**In this repo today:**

- **Manual override path:** `manual_override_processing_ms` on `System_Logs.push` + structured log `alert_manual_override.processing_ms` measures **API-side** processing through FCM attempt.
- **Automated sensor → function path:** when you add **Cloud Functions**, log the same style (`processing_ms`, optional `breach_detected_at`) in the function or in Firestore for dashboards.

---

## 5. Alert latency P1 — **≤ 30 s** (sensor → notification)

**Target:** **Sensor detection → notification received** (ESP32 → ingest → processing → FCM delivery).

| Segment | Suggested timestamps |
|---------|----------------------|
| Detection / ingest | `last_seen_at` or reading doc with server time |
| Processing | Function or API start/end |
| Delivery | FCM outcome already summarized under `System_Logs.push` for manual override |

Use logs + Firestore to **verify** the 30s budget during drills; the repo does not enforce SLO automatically.

---

## 6. Uptime & dashboard (sensor health, ~99.9% mockup)

**Continuous operation** is a **safety** requirement; no specific third-party uptime tool is mandated.

**Implemented (P1):**

- **Admin dashboard — Operations & health:** pings **`GET /health/detailed`** (latency + process `uptime_seconds`) and shows **sensor staleness** from **`IoT_Devices.last_seen_at`** (default **10 min** “stale” threshold in UI; tune to your telemetry interval).
- **Optional external probes:** free **HTTP checks** (host feature, GitHub `schedule` + `curl`, or a free uptime service)—see §8.

Long-term **99.9%** SLO is a **product** goal; compute from historical probes or host metrics when you have enough data.

---

## 7. P1 scope (prototype Option A)

Aligned with **first functional app** / **internal validation**:

- Conventions and **Firestore** foundation (existing schema + logs).
- **Real-time flood alerts** (FCM path documented; manual override in API; automated path when Functions exist).
- **Stability & monitoring:** structured API logs, health endpoints, admin health strip, Firebase Analytics/Crashlytics on admin where applicable.

---

## 8. Implemented artifacts (repo)

| Artifact | Location |
|----------|----------|
| Structured API logs | `backend/api/lib/src/observability_log.dart` — `OPS_STRUCTURED_LOGS=false` to disable |
| Process uptime | `backend/api/lib/src/process_clock.dart` |
| `GET /health/detailed` | `backend/api/routes/health/detailed.dart` — optional env `DEPLOY_VERSION` |
| Manual override timing | `System_Logs.push.manual_override_processing_ms` |
| Admin dashboard panel | `apps/admin_app/.../operations_health_panel.dart` |
| Firebase Analytics / Crashlytics | `apps/admin_app/lib/core/observability/*` (web: Analytics only) |

**Related:** [notifications_fcm_p0.md](notifications_fcm_p0.md), [firestore_schema.md](firestore_schema.md), [backend/api/README.md](../backend/api/README.md), [database_operations.md](database_operations.md).
