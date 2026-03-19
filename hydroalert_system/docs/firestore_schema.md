# Firestore Schema & Enums

**Project:** hydroalert-dev  
**Version:** 1.0 (locked)  
**Last updated:** 2026-03

---

## Collections

### Users

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | yes | User email (from Firebase Auth) |
| `user_type` | enum | yes | One of: `admin`, `official`, `resident` |
| `is_active` | boolean | yes | Account active; false = soft-deleted |
| `created_at` | timestamp | yes | Creation time |
| `updated_at` | timestamp | yes | Last update time |
| `deleted_at` | timestamp | no | Set when soft-deleted |
| `device_tokens` | array\<string\> | no | FCM tokens for push |
| `location` | map | no | `{ lat, lng, zone?, barangay? }` |

**Document ID:** Firebase Auth UID.

---

### Incident_Reports

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `resident_id` | string | yes | UID of reporting resident |
| `status` | enum | yes | `Pending`, `Validated`, `Rejected` |
| `created_at` | timestamp | yes | Report creation time |
| `location` | map | yes | `{ zone, lat?, lng? }` |
| `description` | string | no | Report text |
| `photo_url` | string | no | Photo storage URL |
| `reviewed_by` | string | no | Admin UID (set on review) |
| `reviewed_at` | timestamp | no | Review time |
| `review_notes` | string | no | Notes (required when Rejected) |

**Document ID:** Auto-generated.

---

### Shelters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Shelter name |
| `status` | enum | yes | `Open`, `Closed` |
| `capacity` | number | yes | Max occupancy (≥ 0) |
| `current_occupancy` | number | yes | Current count (0 ≤ x ≤ capacity) |
| `is_active` | boolean | yes | false = soft-deleted |
| `updated_at` | timestamp | yes | Last update |
| `deleted_at` | timestamp | no | Set when soft-deleted |
| `shelter_details` | map | no | Nested: `{ name, status, capacity, current_occupancy, location?, contact?, notes?, is_active?, updated_at?, deleted_at? }` |
| `location` | map | no | `{ zone?, lat?, lng? }` (also in shelter_details) |
| `zone` | string | no | Top-level zone |

**Document ID:** Auto-generated or stable ID.

---

### System_Logs

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | yes | Log type: `report_review`, `user_management_action`, `shelter_update`, `manual_override` |
| `timestamp` | timestamp | yes | Event time |
| `admin_id` | string | no | Admin UID for admin actions |
| `action` | string | no | Action name |
| `target_report_id` | string | no | For report_review |
| `target_user_id` | string | no | For user_management_action |
| `target_shelter_id` | string | no | For shelter_update |
| `target_id` | string | no | Generic target |
| `notes` | string | no | Free text |
| `before` | map | no | Before state |
| `after` | map | no | After state |
| `change_log` | map | no | Change summary |
| `severity` | string | no | For manual_override: Normal, Advisory, Watch, Warning |
| `message` | string | no | For manual_override |
| `target_zone` | string | no | For manual_override |

**Document ID:** Auto-generated.

**Retention:** See [database_operations.md](database_operations.md#system_logs-retention-policy).

---

## Enums (locked)

| Enum | Values |
|------|--------|
| `user_type` | `admin`, `official`, `resident` |
| `report_status` | `Pending`, `Validated`, `Rejected` |
| `shelter_status` | `Open`, `Closed` |
| `alert_severity` | `Normal`, `Advisory`, `Watch`, `Warning` |

---

## Indexes

Required composite indexes are defined in `firestore.indexes.json`. See that file for the full list.

---

## Data Validation on Writes

- **Backend API:** All privileged writes validate enums and constraints before Firestore writes.
- **Firestore rules:** Enforce auth and role checks; do not duplicate complex business logic.
- **Client apps:** Should validate before submit; backend is source of truth.
