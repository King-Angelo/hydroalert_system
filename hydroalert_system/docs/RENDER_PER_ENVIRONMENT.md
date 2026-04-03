# Render (or other host): one service per environment

Each **environment** (dev / staging / production) must have its **own** deploy target: separate URL, **separate Firebase project**, **separate service account JSON**, and **separate non-secret env vars** where values differ (e.g. `CORS_ALLOW_ORIGIN`).

---

## 1. Create three Web Services (Render)

| Render service name (example) | Firebase project (example) | Purpose |
|------------------------------|----------------------------|---------|
| `hydroalert-api-dev` | `hydroalert-dev` | Engineering / noisy data |
| `hydroalert-api-staging` | `hydroalert-staging` | Pre-prod QA |
| `hydroalert-api-production` | `hydroalert-prod` | Live traffic |

For **each** service:

1. **New +** → **Web Service** (or add a second/third service from the same repo).
2. **Root Directory:** monorepo root only — **`./`** if the Git root is **`hydroalert_system`**, or **`hydroalert_system`** if that folder is inside a larger repo. **Not** `backend/api` (Docker needs `packages/shared_models`). **Dockerfile Path:** `backend/api/Dockerfile`.
3. **Runtime:** Docker (same `Dockerfile` for all).
4. **Branch (optional):** e.g. `develop` → dev, `main` → staging + production with **promotion** via separate services (not the same service switching projects).

**Do not** point staging or production at `hydroalert-dev`.

---

## 2. Environment variables (per service)

Set these in the Render dashboard (**Environment** tab) for **that** service only.

### Required (backend)

| Key | dev | staging | production |
|-----|-----|---------|------------|
| `FIREBASE_PROJECT_ID` | `hydroalert-dev` | staging project ID | production project ID |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | JSON for **dev** SA | JSON for **staging** SA | JSON for **production** SA |

Each value is the **full** JSON key for a service account that has access **only** to that Firebase project (download from Firebase Console → Project settings → Service accounts → Generate new private key).

### Strongly recommended

| Key | Notes |
|-----|--------|
| `CORS_ALLOW_ORIGIN` | Origin of the **admin web app** for that tier (e.g. `https://admin-staging.example.com`). Omit or use dev-friendly values only on dev. |
| `FCM_DRY_RUN` | `true` on dev/staging if you want validate-only FCM; `false` in production when ready to send. |
| `FCM_ALERTS_ENABLED` | `false` to disable sends while testing. |
| `CRON_SECRET` | **Different** random secret per environment if you use cron endpoints. |

### Optional / feature flags

See **`docs/examples/backend-api.env.example`** and **`backend/api/DEPLOY_RENDER.md`** (`FCM_INCLUDE_ADMIN_RECIPIENTS`, rate limits, backup bucket, etc.).

**Rule:** Copy the **variable names** across services; **never** copy production `FIREBASE_SERVICE_ACCOUNT_JSON` into staging or dev.

---

## 3. Service account JSON (per tier)

1. In **each** Firebase project, create or use a dedicated service account (least privilege for Firestore + FCM as needed).
2. Download the key **once** per project; store it **only** in Render (or your secret manager), pasted as `FIREBASE_SERVICE_ACCOUNT_JSON`.
3. **Rotate** keys independently per environment; revoking prod must not break dev.

Local development: keep JSON under `backend/api/config/` (folder is **gitignored**).

---

## 4. Blueprint (`render.yaml`)

The repo may include a **single-service** `render.yaml` for quick starts. For **three** services from one blueprint, see **`docs/examples/render-multi-env.yaml`** (copy into `render.yaml` or deploy services manually).

**Secrets:** Do **not** put `FIREBASE_SERVICE_ACCOUNT_JSON` or `CRON_SECRET` in Git. After the blueprint creates services, open each service in the dashboard and add secrets there.

---

## 5. Other hosts (Fly.io, Cloud Run, VPS)

Same rules:

- One logical API deployment per environment.
- Different `FIREBASE_PROJECT_ID` + different service account material per deployment.
- Align `CORS_ALLOW_ORIGIN` with the admin URL for that tier.

---

## Related

- **`docs/environment_separation_p0.md`**
- **`docs/RELEASE_GATE_CHECKLIST.md`**
- **`backend/api/DEPLOY_RENDER.md`**
