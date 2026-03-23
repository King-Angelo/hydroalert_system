# HydroAlert Backend API (Dart Frog)

Privileged admin actions and **FCM zone alerts** (manual override).

## Routes

- `GET /health`
- `POST /v1/reports/review`
- `POST /v1/users/update-role`
- `POST /v1/users/set-active-state`
- `POST /v1/users/soft-delete`
- `POST /v1/shelters/update-status`
- `POST /v1/shelters/update-capacity`
- `POST /v1/shelters/update-occupancy`
- `POST /v1/shelters/soft-delete`
- `POST /v1/alerts/manual-override` — writes `System_Logs`, FCM **token multicast** to users in zone (see [notifications doc](../../docs/notifications_fcm_p0.md))

Cron routes (require `X-Cron-Secret` header, no Firebase token):

- `POST /cron/backup-export` — starts Firestore export to GCS
- `POST /cron/logs-retention` — deletes old `System_Logs` (90-day default)

## Run locally

```bash
dart pub get
dart_frog dev
```

## Auth (Firebase)

V1 routes require a valid Firebase ID token in the `Authorization: Bearer <token>` header.
The backend verifies the token and checks `Users/{uid}` for `user_type == admin` and `is_active == true`.

**Client:** Obtain the ID token from Firebase Auth (`FirebaseAuth.instance.currentUser?.getIdToken()`) and send it as `Authorization: Bearer <token>`.

## Environment

| Variable | Description |
|----------|-------------|
| `FIREBASE_PROJECT_ID` | Firebase project ID (default: `hydroalert-dev`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account JSON (local). On Render use `FIREBASE_SERVICE_ACCOUNT_JSON` via entrypoint. |
| `CORS_ALLOW_ORIGIN` | Optional; set to admin web origin in staging/production (see `_middleware.dart`) |
| `CRON_SECRET` | Required for `/cron/*` routes |
| `BACKUP_BUCKET` / `LOGS_RETENTION_DAYS` | Optional; see cron routes |
| `FCM_ALERTS_ENABLED` | `true` / `false` — disable FCM while keeping audit logs |
| `FCM_DRY_RUN` | `true` — FCM validate-only |
| `FCM_INCLUDE_ADMIN_RECIPIENTS` | `true` — include `user_type` admin when zone matches |
| `ALERT_MIN_INTERVAL_SECONDS` | Default `120` — per-zone flood control (token multicast) |
| `ALERT_DEDUPE_WINDOW_SECONDS` | Default `900` — duplicate payload window |

**Full template:** [docs/examples/backend-api.env.example](../../docs/examples/backend-api.env.example)  
**Multi-environment (dev / staging / prod):** [docs/environment_separation_p0.md](../../docs/environment_separation_p0.md)  
**Alerting / FCM:** [docs/notifications_fcm_p0.md](../../docs/notifications_fcm_p0.md)

## Deploy to Render

See [DEPLOY_RENDER.md](DEPLOY_RENDER.md).
