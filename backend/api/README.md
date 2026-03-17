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

## Run locally

```bash
dart pub get
dart_frog dev
```

## Notes

- `routes/v1/_middleware.dart` currently enforces a scaffold auth contract:
  - `Authorization: Bearer <token>`
  - `x-admin-uid: <uid>` (temporary while Firebase token verification is added)
- Endpoint handlers currently return `202 scaffolded` payloads with validated contracts.
- Next step is replacing scaffold logic with Firebase Admin validation + Firestore writes.
