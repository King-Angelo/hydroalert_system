import '../../iot_devices/data/iot_devices_repository.dart';

/// Staleness: no telemetry in this window ⇒ treat as offline (matches ops health).
const Duration kTelemetryStaleAfter = Duration(minutes: 10);

/// Global flood-depth thresholds in **meters** (inclusive lower bound for higher tiers).
const double kTelemetryAdvisoryM = 3.5;
const double kTelemetryAlertM = 4.5;
const double kTelemetryCriticalM = 6.0;

enum TelemetryDepthSeverity {
  normal,
  advisory,
  alertBand,
  critical,
}

double? maxDepthMetersFromCm(List<double>? channelsCm) {
  if (channelsCm == null || channelsCm.isEmpty) return null;
  var maxCm = channelsCm.first;
  for (var i = 1; i < channelsCm.length; i++) {
    final v = channelsCm[i];
    if (v > maxCm) maxCm = v;
  }
  if (maxCm.isNaN || maxCm < 0) return null;
  return maxCm / 100.0;
}

TelemetryDepthSeverity? severityForDepthMeters(double? depthM) {
  if (depthM == null || depthM.isNaN || depthM < 0) return null;
  if (depthM < kTelemetryAdvisoryM) return TelemetryDepthSeverity.normal;
  if (depthM < kTelemetryAlertM) return TelemetryDepthSeverity.advisory;
  if (depthM < kTelemetryCriticalM) return TelemetryDepthSeverity.alertBand;
  return TelemetryDepthSeverity.critical;
}

/// Fill ratio in [0,1] for a bar capped at [thresholdM].
double barFillRatio(double depthM, double thresholdM) {
  if (thresholdM <= 0) return 0;
  final r = depthM / thresholdM;
  if (r.isNaN) return 0;
  if (r < 0) return 0;
  return r > 1.0 ? 1.0 : r;
}

bool isTelemetryStale(DateTime? lastSeenAt, DateTime now) {
  if (lastSeenAt == null) return true;
  return now.difference(lastSeenAt) > kTelemetryStaleAfter;
}

List<IotDeviceRow> sortedDevicesForTelemetry(List<IotDeviceRow> devices) {
  final copy = List<IotDeviceRow>.from(devices);
  copy.sort((a, b) => a.deviceId.compareTo(b.deviceId));
  return copy;
}
