# Admin app — Firestore writes vs Dart Frog API (alignment)

**Goal:** Move privileged mutations through **`POST /v1/...`** (Firebase ID token) so audit logs and business rules stay consistent, while reads can remain on **Firestore snapshots** until list APIs exist.

**Related:** [backend/api/README.md](../backend/api/README.md), [environment_separation_p0.md](environment_separation_p0.md), [admin_app README](../apps/admin_app/README.md).

---

## Environment

When **`HYDROADMIN_API_BASE_URL`** is set and Firebase initializes, the admin app passes a shared **`AdminAuthenticatedHttpClient`** into:

- Report workflow (validate / reject)
- User management (role, active state, soft-delete)
- Shelter logistics (status, capacity, occupancy, soft-delete)
- Manual override client (same HTTP stack)

If the URL is unset, those flows keep the **legacy Firestore SDK transactions** (and local `System_Logs` shapes) for offline / dev.

---

## Phase 0 — Inventory (source of truth)

Identities: **`reportId`**, **`targetUserId`**, **`shelterId`** = Firestore document ID (PK).

### Mutation map (admin_app)

| UI flow | API route | JSON body |
|--------|-----------|-----------|
| Validate / reject report | `POST /v1/reports/review` | `{ "reportId", "decision": "validated"\|"rejected", "reviewNotes" }` |
| Change role | `POST /v1/users/update-role` | `{ "targetUserId", "nextRole": "official"\|"resident" }` |
| Activate / deactivate | `POST /v1/users/set-active-state` | `{ "targetUserId", "isActive": bool }` |
| Soft-delete user | `POST /v1/users/soft-delete` | `{ "targetUserId" }` |
| Shelter open/close | `POST /v1/shelters/update-status` | `{ "shelterId", "nextStatus": "Open"\|"Closed" }` |
| Shelter capacity | `POST /v1/shelters/update-capacity` | `{ "shelterId", "nextCapacity": int }` |
| Shelter occupancy | `POST /v1/shelters/update-occupancy` | `{ "shelterId", "nextOccupancy": int }` |
| Shelter soft-delete | `POST /v1/shelters/soft-delete` | `{ "shelterId" }` |
| Manual zone alert | `POST /v1/alerts/manual-override` | see [notifications_fcm_p0.md](notifications_fcm_p0.md) |

**Read-only admin repositories:** `FirestoreIotDevicesRepository`, `FirestoreSystemLogsRepository`.

---

## Backend parity (drift resolved for Phase 2)

| Area | Change |
|------|--------|
| **User `set-active-state`** | Sets **`deleted_at`** when `isActive` is false; **`FieldValue.delete`** on `deleted_at` when reactivated (matches admin Firestore path). |
| **User role / active / soft-delete** | **Admin** targets (`user_type == admin`) return **409 conflict** (matches admin app guards). |
| **Shelter writes** | Updates **root** and **`shelter_details.*`** dotted fields (`status`, `capacity`, `current_occupancy`, `is_active`, `deleted_at`, `updated_at`) so UIs reading nested maps stay consistent. |
| **Shelter reads in API** | Capacity / occupancy / status / active flag use the same **root vs `shelter_details`** fallback as [`FirestoreShelterLogisticsRepository`](../apps/admin_app/lib/features/shelters/data/firestore_shelter_logistics_repository.dart) (`v1_shelter_document.dart`). |
| **Shelter soft-delete** | Sets **`status: Closed`**, nested mirrors, idempotent if already inactive. |
| **Report review log** | Still differs from legacy client-only log shape; acceptable for audits via `systemLogBase` until unified. |

---

## Gap list (no `v1` route yet)

| Planned flow | Status |
|--------------|--------|
| Manual water level entry (officials) | **Gap** |
| Sensor `maintenance_log` | **Gap** |
| Officials app mutations | Align when built |

---

## Phases (summary)

1. **Phase 0** — Inventory (this doc).
2. **Phase 1** — Shared **`AdminAuthenticatedHttpClient`**.
3. **Phase 2** — Reports + users + shelters via API when URL configured (**done**); backend drift rows addressed.
4. **Phase 3** — Env/CORS/release gates per [RELEASE_GATE_CHECKLIST.md](RELEASE_GATE_CHECKLIST.md). **Automated v1 smoke:** [admin_api_v1_smoke.md](admin_api_v1_smoke.md) (`backend/api/tool/v1_admin_route_smoke.dart`).
5. **Phase 4** (optional) — Tighten Firestore rules; client writes only for reads.
