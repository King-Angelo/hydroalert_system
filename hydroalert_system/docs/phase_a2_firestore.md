# Phase A2 — Firestore + Firebase options alignment

**Goal:** Keep **`DefaultFirebaseOptions`**, **`firestore.rules`**, and **`firestore.indexes.json`** consistent with app queries so prod/dev do not hit permission errors or missing composite indexes.

---

## 1. DefaultFirebaseOptions

| App | Dev (tracked) | Prod / staging |
|-----|----------------|----------------|
| **admin** | `apps/admin_app/lib/firebase_options.dart` → `firebase_options_dev.dart` | See **`docs/FLUTTERFIRE_BUILD_LANES.md`** — inject or generate per project; do not commit prod keys casually. |
| **resident** | `apps/resident_app/lib/firebase_options.dart` (FlutterFire; android + web) | Same pattern when `hydroalert-prod` exists. |

`HYDRO_ENV` only labels the build; it does **not** switch the Firebase project.

---

## 2. Firestore rules & indexes deploy

From repo root **`hydroalert_system/`** (aliases in **`.firebaserc`**):

```bash
firebase use dev
firebase deploy --only firestore:rules,firestore:indexes
```

Repeat with `firebase use staging` / `production` when those projects are live (**`docs/environment_separation_p0.md`**).

**Index builds** can take minutes in the console; queries that need a composite index fail until status is **Enabled**.

---

## 3. Query ↔ composite indexes (current)

| Collection | Query pattern | `firestore.indexes.json` |
|------------|---------------|----------------------------|
| **Incident_Reports** | `where status` + `orderBy created_at` (admin reports / action queue) | `status` ASC, `created_at` DESC |
| **Users** (FCM multicast) | `where is_active` + `where location.zone` (backend **`alert_notification_service`**) | `is_active` ASC, `location.zone` ASC |
| **IoT_Devices** | Reserved for zone + `last_seen_at` queries | `zone` ASC, `last_seen_at` DESC |

**No composite required for current client patterns:** **Users** pagination uses `orderBy updated_at` + in-memory filter (`FirestoreUserManagementRepository`). **System_Logs** uses `orderBy timestamp` only. **IoT** list uses full-collection snapshots in the admin app today.

When you add new `where` + `orderBy` combinations, update **`firestore.indexes.json`** and redeploy indexes **before** relying on them in production.

---

## 4. Dev project sync

For **`hydroalert-dev`**, rules and indexes from this repo were deployed with:

`firebase use dev` → `firebase deploy --only firestore:rules,firestore:indexes`

Re-run after any change to **`firestore.rules`** or **`firestore.indexes.json`**.
