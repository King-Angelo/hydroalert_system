/// Zone string normalization for **token-based** alerts (rate keys, dedupe metadata).
///
/// P0 does **not** use FCM topic subscription. The backend matches `Users.location.zone`
/// to `targetZone` and sends to `Users.device_tokens`.
abstract final class NotificationTopics {
  /// Stable slug for logging / `Notification_Rate` document ids (not an FCM topic).
  static String slugifyZone(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return 'unknown';

    final buf = StringBuffer();
    var lastUnderscore = false;
    for (final unit in s.runes) {
      final c = String.fromCharCode(unit);
      final isAlnum = (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39) ||
          (c.codeUnitAt(0) >= 0x61 && c.codeUnitAt(0) <= 0x7a);
      if (isAlnum) {
        buf.write(c);
        lastUnderscore = false;
      } else {
        if (!lastUnderscore) {
          buf.write('_');
          lastUnderscore = true;
        }
      }
    }
    var out = buf
        .toString()
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (out.isEmpty) out = 'unknown';
    if (out.length > 200) out = out.substring(0, 200);
    return out;
  }
}
