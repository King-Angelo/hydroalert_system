/// Process start time for coarse API uptime reporting (no external state).
final DateTime hydroalertProcessStartedAt = DateTime.now().toUtc();

/// Seconds since this API process started (for `/health/detailed`).
int hydroalertUptimeSeconds() {
  return DateTime.now().toUtc().difference(hydroalertProcessStartedAt).inSeconds;
}
