/**
 * HydroAlert ESP32 — Anonymous Firebase Auth + Firestore REST telemetry.
 *
 * Requires include/secrets.h (copy from secrets.example.h).
 */
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <sys/time.h>
#include <ArduinoJson.h>

#if __has_include("secrets.h")
#include "secrets.h"
#else
#error "Copy include/secrets.example.h to include/secrets.h and configure."
#endif

#ifndef HA_WIFI_SSID
#error "HA_WIFI_SSID missing in secrets.h"
#endif

namespace {

constexpr unsigned long SAMPLE_INTERVAL_MS = 60UL * 1000UL;
constexpr char kTokenEndpoint[] = "https://securetoken.googleapis.com/v1/token?key=";
constexpr char kSignUpEndpoint[] =
    "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=";

String g_id_token;
String g_refresh_token;
unsigned long g_token_expires_ms = 0;

Preferences prefs;

bool loadTokensFromNvs() {
  if (!prefs.begin(HA_NVS_NAMESPACE, true)) return false;
  g_refresh_token = prefs.getString("rt", "");
  prefs.end();
  return g_refresh_token.length() > 0;
}

void saveRefreshToken(const String &rt) {
  prefs.begin(HA_NVS_NAMESPACE, false);
  prefs.putString("rt", rt);
  prefs.end();
}

bool parseTokenResponse(const JsonDocument &doc) {
  const char *id = doc["id_token"];
  const char *rt = doc["refresh_token"];
  if (!id || !rt) return false;
  g_id_token = id;
  g_refresh_token = rt;
  long exp = doc["expires_in"] | 3600L;
  g_token_expires_ms = millis() + (unsigned long)(exp - 60) * 1000UL;
  saveRefreshToken(g_refresh_token);
  return true;
}

bool httpPostJson(const String &url, const String &body, JsonDocument &out) {
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;
  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");
  int code = http.POST(body);
  String resp = http.getString();
  http.end();
  if (code < 200 || code >= 300) {
    Serial.printf("HTTP %d: %s\n", code, resp.c_str());
    return false;
  }
  DeserializationError err = deserializeJson(out, resp);
  if (err) {
    Serial.println(err.c_str());
    return false;
  }
  return true;
}

bool httpPostForm(const String &url, const String &body, JsonDocument &out) {
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;
  http.begin(client, url);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  int code = http.POST(body);
  String resp = http.getString();
  http.end();
  if (code < 200 || code >= 300) {
    Serial.printf("HTTP %d: %s\n", code, resp.c_str());
    return false;
  }
  DeserializationError err = deserializeJson(out, resp);
  if (err) {
    Serial.println(err.c_str());
    return false;
  }
  return true;
}

bool signUpAnonymous() {
  JsonDocument doc;
  String url = String(kSignUpEndpoint) + HA_FIREBASE_WEB_API_KEY;
  if (!httpPostJson(url, "{\"returnSecureToken\":true}", doc)) return false;
  if (doc.containsKey("error")) {
    serializeJson(doc["error"], Serial);
    Serial.println();
    return false;
  }
  if (!parseTokenResponse(doc)) return false;
  const char *uid = doc["localId"];
  Serial.println("--- Pair this device in Firestore ---");
  Serial.printf("ingest_uid should be: %s\n", uid ? uid : "(unknown)");
  return true;
}

bool refreshIdToken() {
  if (g_refresh_token.isEmpty()) return false;
  JsonDocument doc;
  String url = String(kTokenEndpoint) + HA_FIREBASE_WEB_API_KEY;
  String body = "grant_type=refresh_token&refresh_token=" + g_refresh_token;
  if (!httpPostForm(url, body, doc)) return false;
  if (!parseTokenResponse(doc)) return false;
  return true;
}

bool ensureIdToken() {
  if (g_id_token.length() > 0 && millis() < g_token_expires_ms) return true;
  if (g_refresh_token.isEmpty()) {
    loadTokensFromNvs();
  }
  if (g_refresh_token.isEmpty()) {
    return signUpAnonymous();
  }
  return refreshIdToken();
}

void syncTime() {
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  for (int i = 0; i < 30; ++i) {
    time_t now = time(nullptr);
    if (now > 1700000000) {
      Serial.println("Time synced (UTC).");
      return;
    }
    delay(500);
  }
  Serial.println("Warning: NTP sync failed; timestamps may be wrong.");
}

String rfc3339Now() {
  struct tm ti;
  time_t now = time(nullptr);
  gmtime_r(&now, &ti);
  char buf[40];
  strftime(buf, sizeof buf, "%Y-%m-%dT%H:%M:%S.000Z", &ti);
  return String(buf);
}

bool patchDeviceTelemetry(double ch0, double ch1, double ch2, int battery_mv,
                          int rssi) {
  if (!ensureIdToken()) return false;

  JsonDocument doc(4096);
  JsonObject root = doc.to<JsonObject>();
  JsonObject fields = root["fields"].to<JsonObject>();

  JsonObject lr = fields["latest_reading"]["mapValue"]["fields"].to<JsonObject>();
  lr["recorded_at"]["timestampValue"] = rfc3339Now();
  JsonObject wcm = lr["water_level_cm"]["arrayValue"].to<JsonObject>();
  JsonArray wvals = wcm["values"].to<JsonArray>();
  for (double c : {ch0, ch1, ch2}) {
    JsonObject el = wvals.add<JsonObject>();
    el["doubleValue"] = c;
  }
  lr["battery_mv"]["integerValue"] = battery_mv;
  lr["wifi_rssi_dbm"]["integerValue"] = rssi;

  fields["last_seen_at"]["timestampValue"] = rfc3339Now();
  fields["updated_at"]["timestampValue"] = rfc3339Now();

  String body;
  serializeJson(doc, body);

  String path = String("/v1/projects/") + HA_FIREBASE_PROJECT_ID +
                "/databases/(default)/documents/IoT_Devices/" + HA_IOT_DEVICE_ID +
                "?updateMask.fieldPaths=latest_reading&updateMask.fieldPaths=last_seen_at"
                "&updateMask.fieldPaths=updated_at";

  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;
  http.begin(client, "https://firestore.googleapis.com" + path);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Bearer " + g_id_token);
  int code = http.PATCH(body);
  String resp = http.getString();
  http.end();
  if (code < 200 || code >= 300) {
    Serial.printf("PATCH device failed %d: %s\n", code, resp.c_str());
    return false;
  }
  return true;
}

bool createReadingDoc(double ch0, double ch1, double ch2, int battery_mv,
                      int rssi) {
  if (!ensureIdToken()) return false;

  JsonDocument doc(3072);
  JsonObject root = doc.to<JsonObject>();
  JsonObject fields = root["fields"].to<JsonObject>();
  fields["recorded_at"]["timestampValue"] = rfc3339Now();
  JsonObject wcm = fields["water_level_cm"]["arrayValue"].to<JsonObject>();
  JsonArray wvals = wcm["values"].to<JsonArray>();
  for (double c : {ch0, ch1, ch2}) {
    JsonObject el = wvals.add<JsonObject>();
    el["doubleValue"] = c;
  }
  fields["battery_mv"]["integerValue"] = battery_mv;
  fields["wifi_rssi_dbm"]["integerValue"] = rssi;

  String body;
  serializeJson(doc, body);

  String path =
      String("/v1/projects/") + HA_FIREBASE_PROJECT_ID +
      "/databases/(default)/documents/IoT_Devices/" + HA_IOT_DEVICE_ID +
      "/readings";

  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;
  http.begin(client, "https://firestore.googleapis.com" + path);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Bearer " + g_id_token);
  int code = http.POST(body);
  String resp = http.getString();
  http.end();
  if (code < 200 || code >= 300) {
    Serial.printf("POST reading failed %d: %s\n", code, resp.c_str());
    return false;
  }
  return true;
}

void publishSample() {
  // Replace with real ADC / ultrasonic reads.
  double ch0 = 10.0 + (esp_random() % 100) / 10.0;
  double ch1 = ch0 - 0.5;
  double ch2 = ch0 - 1.0;
  int bat = 3700 + (int)(esp_random() % 200);
  int rssi = WiFi.RSSI();

  if (!patchDeviceTelemetry(ch0, ch1, ch2, bat, rssi)) {
    Serial.println("patchDeviceTelemetry failed");
    return;
  }
  if (!createReadingDoc(ch0, ch1, ch2, bat, rssi)) {
    Serial.println("createReadingDoc failed");
    return;
  }
  Serial.println("Telemetry written.");
}

}  // namespace

void setup() {
  Serial.begin(115200);
  delay(800);
  Serial.println("HydroAlert ESP32 telemetry");

  WiFi.mode(WIFI_STA);
  WiFi.begin(HA_WIFI_SSID, HA_WIFI_PASSWORD);
  Serial.print("WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(400);
    Serial.print(".");
  }
  Serial.println(" OK");
  syncTime();
  loadTokensFromNvs();
  if (!ensureIdToken()) {
    Serial.println("Auth failed; check API key / network.");
  }
}

void loop() {
  static unsigned long last = 0;
  unsigned long now = millis();
  if (now - last >= SAMPLE_INTERVAL_MS) {
    last = now;
    if (WiFi.status() == WL_CONNECTED) {
      publishSample();
    } else {
      Serial.println("WiFi disconnected; reconnecting...");
      WiFi.reconnect();
    }
  }
}
