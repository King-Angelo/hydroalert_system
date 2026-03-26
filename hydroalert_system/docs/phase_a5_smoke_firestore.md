# Phase A5 — Quick Firestore smoke test (`hydroalert-dev`)

**Goal:** Click through the admin app once and confirm Firestore **reads/writes** work (no permission errors, no “missing index” failures). That proves your data shape matches the app code.

**Before:** Log in as an **admin** (`Users` doc: `user_type` admin, `is_active` true). Use project **`hydroalert-dev`**.

**Checklist** (use the left sidebar):

| Screen | Quick check |
|--------|-------------|
| **Dashboard** | Action queue shows **pending** reports (or empty with no error). |
| **Reports** | Change status filter; flip pages if you have many reports; try **validate/reject** once. |
| **User Management** | List loads; change a **non-admin** user if you can. |
| **System Logs** | List loads. |
| **Shelter Logistics** | List loads; change something if the UI allows. |
| **IoT devices** | List loads. |

**OK:** Screens work, data matches **Firestore Console**.  
**Not OK:** Red errors, “permission denied”, or “create index” links → fix **rules/indexes** (Phase A2) or fields vs **`docs/firestore_schema.md`**.

**Extra (optional):** With **`HYDROADMIN_API_BASE_URL`** + API running, check dashboard **health** and **manual alert** — that tests the **HTTP API**, not Firestore mappers.

**More detail:** `firestore_schema.md`, `phase_a2_firestore.md`, `phase_a3_auth.md`.
