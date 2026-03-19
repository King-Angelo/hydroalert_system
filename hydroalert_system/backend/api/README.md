# HydroAlert Backend API (Dart Frog)

This folder contains the P0 backend API scaffold for privileged admin actions.

## Goal

Move privileged writes from client apps to server-side handlers:

- Report decisions
- User role/state updates
- Shelter updates
- Manual override alerts

## Routes scaffolded

- `GET /health`
- `POST /v1/reports/review`
- `POST /v1/users/update-role`
- `POST /v1/users/set-active-state`
- `POST /v1/users/soft-delete`
- `POST /v1/shelters/update-status`
- `POST /v1/shelters/update-capacity`
- `POST /v1/shelters/update-occupancy`
- `POST /v1/shelters/soft-delete`
- `POST /v1/alerts/manual-override`

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

**Environment:**

- `FIREBASE_PROJECT_ID` – Firebase project ID (default: `hydroalert-dev`)
- `GOOGLE_APPLICATION_CREDENTIALS` – Path to service account JSON for Firestore admin check and token verification. Download from [Firebase Console → Project Settings → Service accounts](https://console.firebase.google.com/project/hydroalert-dev/settings/serviceaccounts/adminsdk).

## Deploy to Render

See [DEPLOY_RENDER.md](DEPLOY_RENDER.md) for step-by-step instructions. No GCP billing required.

## Deploy to Render

See [DEPLOY_RENDER.md](DEPLOY_RENDER.md) for step-by-step instructions to deploy to Render (free tier, no GCP billing).

## Deploy to Render

See [DEPLOY_RENDER.md](DEPLOY_RENDER.md) for step-by-step instructions.

## Notes

- Endpoint handlers currently return `202 scaffolded` payloads with validated contracts; Firestore mutation layer is pending.
