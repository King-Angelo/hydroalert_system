#pragma once

// Copy this file to secrets.h (gitignored) and set real values.

#define HA_WIFI_SSID "your-wifi-ssid"
#define HA_WIFI_PASSWORD "your-wifi-password"

// Firebase Web API key (Project settings → General → Web API key)
#define HA_FIREBASE_WEB_API_KEY "your-web-api-key"

#define HA_FIREBASE_PROJECT_ID "hydroalert-dev"

// Must match the Firestore document ID under IoT_Devices/{id}
#define HA_IOT_DEVICE_ID "hydro-demo-01"

// Namespace for NVS
#define HA_NVS_NAMESPACE "hydro_iot"
