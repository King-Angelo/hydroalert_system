# Database Operations (P0)

Backup, restore, and retention for HydroAlert Firestore.

---

## 1. Backup (Manual Export)

For capstone or occasional use, run a manual export when needed (e.g. before demo or submission).

### Prerequisites

1. **GCS bucket** (create once in [Cloud Console → Storage](https://console.cloud.google.com/storage/browser?project=hydroalert-dev)):
   - Name: `hydroalert-dev-backups`
   - Or use any bucket you have in the project

2. **Google Cloud SDK** (for `gcloud`) – [Install](https://cloud.google.com/sdk/docs/install) if not present.

### Manual Export

```bash
gcloud firestore export gs://hydroalert-dev-backups/manual-YYYYMMDD --project=hydroalert-dev
```

Replace `YYYYMMDD` with today’s date (e.g. `20260319`).

**PowerShell example:**

```powershell
$date = Get-Date -Format "yyyyMMdd"
gcloud firestore export "gs://hydroalert-dev-backups/manual-$date" --project=hydroalert-dev
```

### Restore from Export

```bash
gcloud firestore import gs://hydroalert-dev-backups/manual-YYYYMMDD --project=hydroalert-dev
```

---

## 2. Cron API — Automated Backup & Retention (Option 3)

When your Dart Frog backend is hosted (e.g. VPS, Cloud Run), you can trigger backup and retention from an external scheduler **without Firebase Blaze**.

### Environment Variables

Set these on your backend host:

| Variable | Required | Description |
|----------|----------|-------------|
| `CRON_SECRET` | Yes | Shared secret; cron requests must send it in `X-Cron-Secret` header |
| `BACKUP_BUCKET` | For backup | GCS URI, e.g. `gs://hydroalert-dev-backups` |
| `LOGS_RETENTION_DAYS` | No | Days to keep System_Logs; default `90` |

### Endpoints

Both require `POST` and `X-Cron-Secret: <CRON_SECRET>`.

| Endpoint | Purpose |
|----------|---------|
| `POST /cron/backup-export` | Starts Firestore export to GCS (output: `$BACKUP_BUCKET/export-YYYYMMDD`) |
| `POST /cron/logs-retention` | Deletes `System_Logs` older than `LOGS_RETENTION_DAYS` |

### cron-job.org Setup

1. [cron-job.org](https://cron-job.org) → Create free account → New cron job.
2. **Backup** (e.g. weekly):
   - URL: `https://your-api-host/cron/backup-export`
   - Method: `POST`
   - Headers: `X-Cron-Secret: <your-secret>`
   - Schedule: e.g. every Sunday 02:00
3. **Retention** (e.g. daily):
   - URL: `https://your-api-host/cron/logs-retention`
   - Method: `POST`
   - Headers: `X-Cron-Secret: <your-secret>`
   - Schedule: e.g. every day 03:00

### GitHub Actions Alternative

```yaml
- name: Trigger backup
  run: |
    curl -X POST "${{ secrets.API_URL }}/cron/backup-export" \
      -H "X-Cron-Secret: ${{ secrets.CRON_SECRET }}"
```

---

## 3. System_Logs Retention (Manual / Blaze)

- **Cron API**: Use `POST /cron/logs-retention` as above.
- **Manual**: Run a one-off script when needed.
- **Blaze**: Enable Cloud Functions scheduled retention if migrating later.

---

## 4. Deployment (Rules & Indexes)

```bash
cd hydroalert_system
firebase use hydroalert-dev
firebase deploy --only firestore
```

This deploys Firestore rules and indexes only.
