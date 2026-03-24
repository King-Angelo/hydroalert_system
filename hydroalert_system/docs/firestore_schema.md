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
| `push` | map | no | For `manual_override`: FCM **token multicast** outcome (`mode`, `token_count`, `success_count`, `failure_count`, `duplicate`, `rate_limited`, `dry_run`, `zone_slug`, `error`) plus **`manual_override_processing_ms`** (API alert-processing time for P1 observability). See [notifications_fcm_p0.md](notifications_fcm_p0.md) and [observability_p1.md](observability_p1.md). |

**Document ID:** Auto-generated.

**Retention:** See [database_operations.md](database_operations.md#system_logs-retention-policy).

---

### Notification_Dedupe

Server-only (Admin SDK). Prevents identical **manual override** payloads from generating multiple FCM sends within a configurable time bucket.

| Field | Type | Description |
|-------|------|-------------|
| `kind` | string | e.g. `manual_override` |
| `created_at` | timestamp | Reservation time |
| `target_zone` | string | Original zone string |
| `severity` | string | Severity |
| `admin_id` | string | Admin UID |
| `zone_slug` | string | Stable slug for rate keys / logs |
| `delivery` | string | `token_multicast` |
| `status` | string | `pending` → `sent` / `dry_run`; doc deleted if send fails or no tokens (retry allowed) |
| `message_preview` | string | Truncated message |
| `token_count` | number | no | Recipient tokens |
| `success_count` | number | no | FCM successes |
| `failure_count` | number | no | FCM failures |
| `sent_at` | timestamp | no | Set after successful send |

**Document ID:** SHA-256 hex of `(kind, zone, severity, message, time_bucket)`.

---

### Notification_Rate

Server-only. Per **zone slug** last send time for flood control (token multicast).

| Field | Type | Description |
|-------|------|-------------|
| `last_sent_at` | timestamp | Last successful (or dry-run) send |
| `zone_slug` | string | Stable slug |
| `target_zone` | string | Original zone string from last send |
| `last_severity` | string | no | Last severity sent |
| `last_admin_id` | string | no | Last admin UID |
| `last_token_count` | number | no | Tokens in last send |

**Document ID:** `zone_{slug}` (e.g. `zone_district_1`).

---

### IoT_Devices

Water-level monitoring stations (ESP32). One document per physical device.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `device_id` | string | yes | Same as document ID |
| `name` | string | no | Human label (e.g. bridge upstream) |
| `zone` | string | no | Aligns with shelters / reports |
| `location` | map | no | `{ lat?, lng? }` |
| `sensor_count` | number | yes | `3` for P0 (three water-level channels) |
| `firmware_version` | string | no | e.g. `0.1.0` |
| `is_active` | boolean | yes | Admin can disable a unit |
| `ingest_uid` | string | no | Firebase Auth UID allowed to write telemetry (see below) |
| `created_at` | timestamp | yes | |
| `updated_at` | timestamp | yes | Last metadata or telemetry touch |
| `last_seen_at` | timestamp | no | Last successful telemetry write |
| `latest_reading` | map | no | Denormalized snapshot for dashboards (see below) |

**`latest_reading` map**

| Subfield | Type | Description |
|----------|------|-------------|
| `recorded_at` | timestamp | Sample time on device |
| `received_at` | timestamp | Optional; server accept time |
| `water_level_cm` | array\<number\> | Length **3**: `[ch0, ch1, ch2]` in centimeters |
| `battery_mv` | number | optional |
| `wifi_rssi_dbm` | number | optional |

**Document ID:** Stable id burned in firmware (e.g. `hydro-bridge-01`).

**Device writes (direct Firebase):** The ESP32 signs in with Firebase Auth (e.g. **Anonymous** with credentials stored in NVS, or a **dedicated** email/password device user). An admin sets **`ingest_uid`** on this document to that user’s UID once (minimal pairing). Firestore rules allow that UID to update telemetry fields and append `readings` only.

**Alerts:** Local on device only; no cloud alert documents required for P0.

**Pairing:** See [iot_device_pairing.md](iot_device_pairing.md).

---

### IoT_Devices / `{deviceId}` / readings (subcollection)

Time-series samples for charts and history.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `recorded_at` | timestamp | yes | Device sample time |
| `water_level_cm` | array\<number\> | yes | Length **3** |
| `battery_mv` | number | no | |
| `wifi_rssi_dbm` | number | no | |
| `raw_adc` | array\<number\> | no | Optional calibration / debug |

**Document ID:** Auto-generated.

---

## Enums (locked)

| Enum | Values |
|------|--------|
| `user_type` | `admin`, `official`, `resident` |
| `report_status` | `Pending`, `Validated`, `Rejected` |
| `shelter_status` | `Open`, `Closed` |
| `alert_severity` | `Normal`, `Advisory`, `Watch`, `Warning` |
| `iot_device_status` | (optional future) `ok`, `degraded`, `sensor_fault` |

---

## Indexes

Required composite indexes are defined in `firestore.indexes.json`. See that file for the full list.

---

## Data Validation on Writes

- **Backend API:** All privileged writes validate enums and constraints before Firestore writes.
- **Firestore rules:** Enforce auth and role checks; do not duplicate complex business logic.
- **Client apps:** Should validate before submit; backend is source of truth.
