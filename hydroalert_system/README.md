# HydroAlert system

Monorepo for the HydroAlert platform: **resident / official / admin** Flutter apps, **Dart Frog** backend API, **shared_models**, and **firmware** tooling.

## Environment separation (P0)

- **[docs/environment_separation_p0.md](docs/environment_separation_p0.md)** — dev / staging / production Firebase projects, secrets, and admin build flags (`HYDRO_ENV`, `HYDROADMIN_API_BASE_URL`).
- **[docs/RENDER_PER_ENVIRONMENT.md](docs/RENDER_PER_ENVIRONMENT.md)** — separate Render (or other host) services, env vars, and service account JSON **per tier**.
- **[docs/GITHUB_BRANCH_PROTECTION.md](docs/GITHUB_BRANCH_PROTECTION.md)** — require CI on **`main`** (status check names).
- **[docs/FLUTTERFIRE_BUILD_LANES.md](docs/FLUTTERFIRE_BUILD_LANES.md)** — regenerate `firebase_options` per build lane; keep production out of casual commits (CI policy + optional staging workflow).
- **[docs/RELEASE_GATE_CHECKLIST.md](docs/RELEASE_GATE_CHECKLIST.md)** — manual gates before promoting staging → production.
- **[docs/examples/backend-api.env.example](docs/examples/backend-api.env.example)** — backend env template (never commit real values).

Firebase CLI aliases live in **[`.firebaserc`](.firebaserc)**. Replace `hydroalert-staging` / `hydroalert-prod` with your real project IDs after you create those projects.

## CI (release gate)

On pull requests and pushes to `main`/`master`, **[`.github/workflows/ci.yml`](.github/workflows/ci.yml)** runs: **Backend API** (`dart analyze`), **shared_models** (`dart test`), **Admin app** (`flutter analyze`), and **Firebase options policy** (blocks committing production Firebase project id into tracked `firebase_options*.dart`). **Repo root for GitHub** should be this folder (`hydroalert_system`); if your remote root is the parent directory, move `.github` to the repo root and prefix paths (e.g. `hydroalert_system/backend/api`). Required check names for branch protection: **`docs/GITHUB_BRANCH_PROTECTION.md`**.

## Observability (P1)

- **[docs/observability_p1.md](docs/observability_p1.md)** — Firebase **Spark**, log audiences & retention, serverless “queue” / **≤30s** alert path, **sensor health** + API uptime on the admin dashboard, optional external probes.

## Where to go next

| Area | Doc / entry |
|------|-------------|
| API on Render | [backend/api/DEPLOY_RENDER.md](backend/api/DEPLOY_RENDER.md) |
| Backend API | [backend/api/README.md](backend/api/README.md) |
| Admin app | [apps/admin_app/README.md](apps/admin_app/README.md) |
