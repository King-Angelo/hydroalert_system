# Alerting & notifications (P0) — FCM **without topic subscription**

HydroAlert P0 sends push via **FCM registration tokens** stored on **`Users.device_tokens`**. There is **no** `subscribeToTopic` / FCM topic fan-out.

The **Dart Frog API** triggers sends on **`POST /v1/alerts/manual-override`**.

---

## 1. Production keys & console setup

1. **Firebase Console** → **Project settings** → **Cloud Messaging**.
2. **Android** — Register the app; use **`google-services.json`** (FlutterFire).
3. **Apple (APNs)** — Upload APNs key/certs for iOS push.
4. **Web** — Web Push / **VAPID** if you add web clients later.
5. **Service account** (backend / Render) — Same JSON as Firestore; must be allowed to call **FCM**.

---

## 2. How targeting works (no “geofence” in FCM)

| Layer | Behavior |
|-------|----------|
| **Zone match** | Backend queries `Users` where `is_active == true` and **`location.zone` == `targetZone`** (exact string match after trim on API). |
| **Tokens** | For each user, every non-empty string in **`device_tokens`** receives the multicast (deduped across users). |
| **Admins** | By default **`user_type == admin`** is **excluded** from recipients. Set env **`FCM_INCLUDE_ADMIN_RECIPIENTS=true`** to include them (e.g. testing). |
| **GIS** | True lat/lng geofencing is **not** in FCM. Use consistent **`location.zone`** values from your profile UX / data entry. |

**Resident (or official) app** is **not required** for P0 if you only care about **admin + API**: tokens must still be **written to Firestore** (any path you choose later). For a quick test, set **`device_tokens`** + **`location.zone`** on a **test user** in the console.

---

## 3. Admin-only focus

- **Admin app / API** can drive **manual override** and **monitoring** via **`System_Logs.push`** and **`Notification_*`** collections.
- You do **not** need the **`resident_app`** package for alerting P0. Keep it as a stub until you build the resident UX and token registration there (or in **`official_app`**).

---

## 4. Delivery & error monitoring

| Source | What to inspect |
|--------|------------------|
| **`System_Logs`** | `manual_override` rows include **`push`**: `mode`, `token_count`, `success_count`, `failure_count`, `duplicate`, `rate_limited`, `dry_run`, `zone_slug`, `error`. |
| **`Notification_Dedupe`** | Dedupe + send outcome metadata. |
| **`Notification_Rate`** | Doc id `zone_{slug}` — last send time for rate limiting. |

---

## 5. Rate limit & duplicate prevention

| Variable | Default | Purpose |
|----------|---------|---------|
| `FCM_ALERTS_ENABLED` | `true` | `false` = no FCM; log still records `skipped_disabled`. |
| `FCM_DRY_RUN` | `false` | `true` = FCM validate-only. |
| `FCM_INCLUDE_ADMIN_RECIPIENTS` | `false` | Include admins as recipients when their `location.zone` matches. |
| `ALERT_MIN_INTERVAL_SECONDS` | `120` | Min time between **successful** multicast rounds for the **same zone slug**. |
| `ALERT_DEDUPE_WINDOW_SECONDS` | `900` | Identical payload in the same wall-clock bucket is **duplicate** (no second send). |

**Firestore index:** composite on **`Users`**: `is_active` + **`location.zone`** — see `firestore.indexes.json`.

---

## 6. Related code

| Area | Path |
|------|------|
| Zone slug helper | `packages/shared_models/lib/src/fcm/notification_topics.dart` (`slugifyZone` only) |
| Send + gates | `backend/api/lib/src/alert_notification_service.dart` |
| Trigger | `backend/api/routes/v1/alerts/manual-override.dart` |

---

## 7. Environment separation (P0)

Use **different Firebase projects** (and different service accounts / Render services) for dev, staging, and production so FCM and Firestore data never leak across tiers. See **[environment_separation_p0.md](environment_separation_p0.md)** and **[RENDER_PER_ENVIRONMENT.md](RENDER_PER_ENVIRONMENT.md)**.

---

## 8. Optional P1

- Cron cleanup of old **`Notification_Dedupe`** docs.
- Client SDK: obtain FCM token → **`arrayUnion`** into **`Users.device_tokens`** on sign-in.

---

## 9. Latency & operations (≤30s target)

End-to-end **sensor → notification** timing and dashboard/ops conventions: **[observability_p1.md](observability_p1.md)**.
