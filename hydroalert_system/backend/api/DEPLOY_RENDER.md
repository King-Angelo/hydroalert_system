# Deploy HydroAlert API to Render

Deploy the Dart Frog backend to [Render](https://render.com) (no GCP billing required).

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
   - **Root Directory:** `backend/api` *(if repo root is `hydroalert_system`)* — or `hydroalert_system/backend/api` *(if repo root is the parent folder)*
   - **Environment:** `Docker`
   - **Region:** Choose nearest (e.g. Singapore, Oregon)
   - **Plan:** Free

4. **Environment Variables** (Add in Render dashboard):

   | Key | Value | Notes |
   |-----|-------|-------|
   | `FIREBASE_PROJECT_ID` | `hydroalert-dev` | Your Firebase project |
   | `FIREBASE_SERVICE_ACCOUNT_JSON` | `{ ... }` | Full JSON from service account file (paste entire content) |
   | `CRON_SECRET` | `your-random-secret` | For cron endpoints (optional) |
   | `BACKUP_BUCKET` | `gs://hydroalert-dev-backups` | For backup export (optional) |

   **Getting the service account JSON:**
   - Firebase Console → Project Settings → Service accounts → Generate new private key
   - Open the downloaded JSON file
   - Copy the entire content (including `{` and `}`)
   - Paste as the value of `FIREBASE_SERVICE_ACCOUNT_JSON` in Render

5. Click **Create Web Service**

Render will build the Docker image and deploy. First deploy may take ~5–10 minutes.

---

## Step 3: Get Your API URL

After deploy, Render shows a URL like:

```
https://hydroalert-api-xxxx.onrender.com
```

Use this as the base URL for your Flutter apps (e.g. in API config).

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
| **`open Dockerfile: no such file or directory`** | Wrong Root Directory. Try `backend/api` (if repo root is `hydroalert_system`). Or use **Blueprint** deploy: Dashboard → New → Blueprint → connect repo — `render.yaml` in the repo configures the path. |
| Build fails on `dart_frog build` | Ensure Root Directory is correct and Dockerfile exists at that path |
| Firestore permission denied | Verify `FIREBASE_SERVICE_ACCOUNT_JSON` is valid and has Firestore access |
| 502 Bad Gateway | Check Render logs; service may be starting. Wait for cold start. |
