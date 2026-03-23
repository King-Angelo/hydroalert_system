# HydroAlert ESP32 firmware (P0)

Anonymous Firebase Auth + Firestore REST writes for `IoT_Devices/{id}` and `readings` subcollection.

## Prerequisites

- [PlatformIO](https://platformio.org/) (VS Code extension or CLI)
- Wi-Fi and Firebase **Web API key** (not the service account)
- A document in Firestore `IoT_Devices/{HA_IOT_DEVICE_ID}` with `ingest_uid` set to this device’s Firebase Auth UID (see [docs/iot_device_pairing.md](../../docs/iot_device_pairing.md))

## Setup

1. Copy `include/secrets.example.h` → `include/secrets.h`
2. Fill Wi-Fi, API key, project id, device id
3. Build & upload:
   ```bash
   cd firmware/esp32-hydroalert
   pio run -t upload
   pio device monitor
   ```

On first boot the firmware signs in anonymously and prints the **localId** (UID). Set `ingest_uid` on the device document to that UID, then reboot or wait for the next telemetry cycle.

## Security note

TLS uses `setInsecure()` for a smaller footprint on ESP32. For production, pin roots or use `WiFiClientSecure` cert bundles.

## Telemetry interval

Default: 60 seconds between samples (see `SAMPLE_INTERVAL_MS` in `src/main.cpp`).
