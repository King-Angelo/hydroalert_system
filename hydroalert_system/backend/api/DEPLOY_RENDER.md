# Deploy HydroAlert API to Render

Deploy the Dart Frog backend to [Render](https://render.com) (no GCP billing required).

**Repo layout:** The API **`Dockerfile` must build with context = the folder that contains `packages/` and `backend/`** (usually the **`hydroalert_system`** Git root), because **`pubspec.yaml`** depends on **`path: ../../packages/shared_models`**.

| Git remote root | Render **Root Directory** | Render **Dockerfile Path** |
|-----------------|---------------------------|----------------------------|
| **`King-Angelo/hydroalert_system`** (clone has a single top-level folder **`hydroalert_system/`**) | **`hydroalert_system`** | **`backend/api/Dockerfile`** |
| **`hydroalert_system`** fork with `apps/`, `backend/`, `packages/` at **repo** root | **`./`** (leave empty) | **`backend/api/Dockerfile`** |
| **`Development_of_hydroalert`** (parent repo with `hydroalert_system/` inside) | **`hydroalert_system`** | **`backend/api/Dockerfile`** |

Do **not** set Root Directory to **`backend/api` only** — Docker will not see **`packages/shared_models`** and `dart pub get` will fail (e.g. exit code **66**).

**Environment separation (P0):** Use **one Render Web Service per environment** (dev / staging / production) with **different** `FIREBASE_PROJECT_ID`, service account JSON, and secrets. Do not point staging at the prod Firebase project. See **[`docs/RENDER_PER_ENVIRONMENT.md`](../../docs/RENDER_PER_ENVIRONMENT.md)** (matrix + SA JSON per tier), [`docs/environment_separation_p0.md`](../../docs/environment_separation_p0.md), and [`docs/RELEASE_GATE_CHECKLIST.md`](../../docs/RELEASE_GATE_CHECKLIST.md). Blueprint example: [`docs/examples/render-multi-env.yaml`](../../docs/examples/render-multi-env.yaml).

---

## Prerequisites

1. **Render account** — [Sign up free](https://render.com)
2. **GitHub** — Push your code to a repo (Render deploys from GitHub)
3. **Firebase service account** — For Firestore (download from Firebase Console → Project Settings → Service accounts)

---

## Step 1: Push to GitHub

If not already:

```powershell
cd C:\src\Development_of_hydroalert
git add .
git commit -m "Add Render deployment config"
git push origin main
```

---

## Step 2: Create Web Service on Render

1. Go to [Render Dashboard](https://dashboard.render.com) → **New +** → **Web Service**
2. Connect your GitHub account and select the repo (`Development_of_hydroalert` or similar)
3. **Settings:**
   - **Name:** `hydroalert-api`
   - **Root Directory:** see table above *(monorepo root, **not** `backend/api` alone)*
   - **Dockerfile Path:** `backend/api/Dockerfile`
   - **Environment:** `Docker`
   - **Region:** Choose nearest (e.g. Singapore, Oregon)
   - **Plan:** Free

4. **Phase 3 (after first deploy)** — `GET /health` on your URL; tier-1 smoke: from `hydroalert_system/backend/api` run `dart run tool/v1_admin_route_smoke.dart` with `SMOKE_API_BASE` set ([`docs/admin_api_v1_smoke.md`](../../docs/admin_api_v1_smoke.md)); set `CORS_ALLOW_ORIGIN` when admin web has a fixed origin. Full list: [`docs/RELEASE_GATE_CHECKLIST.md`](../../docs/RELEASE_GATE_CHECKLIST.md) section B.

5. **Environment Variables** (Add in Render dashboard):

   | Key | Value | Notes |
   |-----|-------|-------|
   | `FIREBASE_PROJECT_ID` | `hydroalert-dev` | **Must match** the Firebase project used by the **admin web** build (`DefaultFirebaseOptions.projectId` / `firebase_options.dart`). If Render uses a different project than the browser app, ID token verification fails (often `TypeError` / “Null check operator” in logs). |
   | `FIREBASE_SERVICE_ACCOUNT_JSON` | `{...}` | **Must be valid JSON.** Prefer **one line** (see below). |
   | `FIREBASE_SERVICE_ACCOUNT_JSON_B64` | *(optional)* | **Recommended on Render:** base64 of the entire `.json` file (no newlines). Avoids paste errors with `private_key`. |
   | `CRON_SECRET` | `your-random-secret` | For cron endpoints (optional) |
   | `BACKUP_BUCKET` | `gs://hydroalert-dev-backups` | For backup export (optional) |
   | `FCM_ALERTS_ENABLED` | `true` | Set `false` to disable FCM sends (audit log still records `push.skipped_disabled`) |
   | `FCM_DRY_RUN` | `false` | `true` = FCM validate-only (no delivery) |
   | `FCM_INCLUDE_ADMIN_RECIPIENTS` | `false` | `true` = also push to admins whose `location.zone` matches |
   | `ALERT_MIN_INTERVAL_SECONDS` | `120` | Min seconds between sends for the same zone (rate key) |
   | `ALERT_DEDUPE_WINDOW_SECONDS` | `900` | Dedupe bucket size (seconds) for identical payloads |
   | `CORS_ALLOW_ORIGIN` | `https://hydroalert-staging.web.app` | **Required for Flutter web admin** calling this API from the browser. Use your Hosting URL exactly (no trailing slash). Optional comma-separated second origin: `https://your-project.firebaseapp.com`. |

   **FCM / alerting:** See [docs/notifications_fcm_p0.md](../docs/notifications_fcm_p0.md).

   **Getting the service account JSON (staging / prod):**
   - Firebase Console → Project Settings → Service accounts → Generate new private key
   - **Do not** paste multiline JSON into Render if the editor turns `private_key` into real line breaks — JSON allows only `\n` **inside the string**, not literal newlines. That causes: `FormatException: Control character in string` when verifying tokens.
   - **Option A (recommended):** Base64 the file and set **`FIREBASE_SERVICE_ACCOUNT_JSON_B64`** (see `entrypoint.sh`):
     - Linux: `base64 -w0 < your-project.json`
     - macOS: `base64 -i your-project.json | tr -d '\n'`
     - Paste the **single** base64 string as the env value (no variable name in the value).
   - **Option B:** Minify to one line, then set **`FIREBASE_SERVICE_ACCOUNT_JSON`**: `jq -c . your-project.json` and paste the output.

6.  Click **Create Web Service**

Render will build the Docker image and deploy. First deploy may take ~5–10 minutes.

---

## Step 3: Get Your API URL

After deploy, Render shows a URL like:

```
https://hydroalert-api-xxxx.onrender.com
```

Use this as the base URL for your Flutter apps (e.g. in API config).

**Uptime / ops (P1, free):** `GET /health` and `GET /health/detailed` (JSON includes `uptime_seconds`). Logs: structured JSON on stdout — see [docs/observability_p1.md](../../docs/observability_p1.md).

---

## Step 4: Configure Cron (Optional)

If using backup/retention endpoints, add jobs at [cron-job.org](https://cron-job.org):

- **Backup:** `POST https://your-render-url.onrender.com/cron/backup-export`  
  Header: `X-Cron-Secret: <CRON_SECRET>`
- **Retention:** `POST https://your-render-url.onrender.com/cron/logs-retention`  
  Header: `X-Cron-Secret: <CRON_SECRET>`

---

## Free Tier Notes

- Service sleeps after ~15 minutes of inactivity
- First request after sleep may take 30–60 seconds (cold start)
- ~750 hours/month free

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| **`Root directory "Dockerfile" does not exist`** | **Root Directory** must be a **folder name** (e.g. **`hydroalert_system`** for this GitHub repo), not the Dockerfile path. Put **`backend/api/Dockerfile`** only in **Dockerfile Path**. |
| **`invalid local` / `lstat .../backend`** | Render is resolving paths from the **Git** root, but **`backend/`** lives under **`hydroalert_system/`**. Set **Root Directory** to **`hydroalert_system`** (see table). |
| **`open Dockerfile: no such file or directory`** | **Root Directory** = monorepo folder; **Dockerfile Path** = **`backend/api/Dockerfile`** (relative to that root). |
| Build fails on `dart_frog build` or **`dart pub get` exit 66** | Same as above — context must include **`packages/shared_models`**. |
| Firestore permission denied | Verify `FIREBASE_SERVICE_ACCOUNT_JSON` is valid and has Firestore access |
| **`Token verification failed: FormatException: Control character in string`… `private_key`** | Service account JSON on the server is **invalid** (usually literal newlines in `private_key`). Use **`FIREBASE_SERVICE_ACCOUNT_JSON_B64`** or **`jq -c .`** minified JSON — see **Environment Variables** above. Redeploy after fixing. |
| 502 Bad Gateway | Check Render logs; service may be starting. Wait for cold start. |
| **CORS** / `No 'Access-Control-Allow-Origin'` on admin web | Set **`CORS_ALLOW_ORIGIN`** on the API service to your Firebase Hosting origin (e.g. `https://hydroalert-staging.web.app`). Redeploy. If you still see 500, check Render logs — unhandled errors now still include CORS headers. |
| **401** + `Token verification failed` + `_TypeError` / null check | **Project mismatch:** `FIREBASE_PROJECT_ID` on Render must equal the Firebase project your **admin web** uses (check `firebase_options.dart` / build flavor). Rebuild and redeploy admin web if you changed projects; fix Render env and redeploy API. No extra Firebase Hosting “UI” setting fixes this — it is env alignment. |
| **`POST /v1/alerts/manual-override` → 500** | Open the response JSON in DevTools (or Render logs). **`firestore_error` + `failed_precondition`** often means a **missing composite index** for `Users` (`is_active` + `location.zone`): deploy indexes from the repo with `firebase deploy --only firestore:indexes` to the **same** project as **`FIREBASE_PROJECT_ID`**. **`messaging_error`** → enable **Firebase Cloud Messaging API** in Google Cloud for that project; confirm **`FIREBASE_PROJECT_ID`** matches the Firebase project used by the admin web app. |
