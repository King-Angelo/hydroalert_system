# IoT device pairing (P0)

Minimal steps so an ESP32 can write to `IoT_Devices` under Firestore rules.

## Model

- Each device has a document `IoT_Devices/{deviceId}`.
- Field **`ingest_uid`** must equal the Firebase Auth **UID** used by the firmware when it writes.
- Firmware signs in with Firebase Auth (recommended: **Anonymous**, store refresh token in NVS after first boot).

## One-time setup (admin)

1. Flash firmware so the device signs in anonymously once.
2. In **Firebase Console → Authentication**, copy the **User UID** for that session.
3. In **Firestore**, create `IoT_Devices/{deviceId}` with at least:

   - `device_id` — same as document id  
   - `sensor_count` — `3`  
   - `is_active` — `true`  
   - `ingest_uid` — paste the UID from step 2  
   - `created_at`, `updated_at` — timestamps  

4. The device may then update telemetry fields and append `readings/` subcollection docs.

## Reference firmware

See `firmware/esp32-hydroalert/` (PlatformIO): anonymous sign-in, NVS refresh token, Firestore REST `PATCH` on `latest_reading` + `POST` to `readings`.

## Notes

- Admin SDK bypasses rules for full document management.
- See [firestore_schema.md](firestore_schema.md) for full field list.
