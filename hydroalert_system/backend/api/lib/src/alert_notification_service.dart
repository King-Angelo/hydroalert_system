import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dart_firebase_admin_plus/firestore.dart';
import 'package:dart_firebase_admin_plus/messaging.dart';
import 'package:shared_models/shared_models.dart';

/// P0 **token multicast** FCM (no topic subscription): targets active users whose
/// `Users.location.zone` equals [targetZone] and who have `device_tokens`.
class AlertNotificationService {
  AlertNotificationService._();

  static const _dedupeCollection = 'Notification_Dedupe';
  static const _rateCollection = 'Notification_Rate';
  static const _usersCollection = 'Users';

  static bool get _fcmEnabled {
    final v = Platform.environment['FCM_ALERTS_ENABLED']?.toLowerCase();
    if (v == null || v.isEmpty) return true;
    return v == '1' || v == 'true' || v == 'yes';
  }

  static bool get _dryRun {
    final v = Platform.environment['FCM_DRY_RUN']?.toLowerCase();
    return v == '1' || v == 'true' || v == 'yes';
  }

  static bool get _includeAdminRecipients {
    final v = Platform.environment['FCM_INCLUDE_ADMIN_RECIPIENTS']?.toLowerCase();
    return v == '1' || v == 'true' || v == 'yes';
  }

  static int get _minIntervalSeconds {
    final raw = Platform.environment['ALERT_MIN_INTERVAL_SECONDS'];
    final parsed = int.tryParse(raw ?? '');
    if (parsed == null || parsed < 0) return 120;
    return parsed;
  }

  static int get _dedupeWindowSeconds {
    final raw = Platform.environment['ALERT_DEDUPE_WINDOW_SECONDS'];
    final parsed = int.tryParse(raw ?? '');
    if (parsed == null || parsed < 30) return 900;
    return parsed;
  }

  /// Sends a **manual override** via FCM to registration tokens (no `subscribeToTopic`).
  static Future<ZoneAlertSendResult> sendManualOverrideToZone({
    required Firestore firestore,
    required Messaging messaging,
    required String adminUid,
    required String targetZone,
    required String severity,
    required String message,
  }) async {
    final zoneTrim = targetZone.trim();
    final zoneSlug = NotificationTopics.slugifyZone(zoneTrim);
    final rateDocId = 'zone_$zoneSlug';

    if (!_fcmEnabled) {
      return ZoneAlertSendResult(
        attempted: false,
        skippedDisabled: true,
        duplicate: false,
        rateLimited: false,
        dryRun: false,
        zoneSlug: zoneSlug,
        tokenCount: 0,
        successCount: 0,
        failureCount: 0,
        error: null,
      );
    }

    final rateRef = firestore.collection(_rateCollection).doc(rateDocId);
    final rateSnap = await rateRef.get();
    if (rateSnap.exists) {
      final data = rateSnap.data() as Map<String, dynamic>?;
      final last = data?['last_sent_at'];
      if (last is Timestamp) {
        final lastDt = DateTime.fromMillisecondsSinceEpoch(
          last.seconds * 1000 + last.nanoseconds ~/ 1000000,
          isUtc: true,
        );
        final elapsed = DateTime.now().toUtc().difference(lastDt);
        if (elapsed.inSeconds < _minIntervalSeconds) {
          return ZoneAlertSendResult(
            attempted: false,
            skippedDisabled: false,
            duplicate: false,
            rateLimited: true,
            dryRun: _dryRun,
            zoneSlug: zoneSlug,
            tokenCount: 0,
            successCount: 0,
            failureCount: 0,
            error:
                'rate_limited: min interval ${_minIntervalSeconds}s '
                '(elapsed ${elapsed.inSeconds}s)',
          );
        }
      }
    }

    final dedupeId = _dedupeId(
      zone: zoneTrim,
      severity: severity,
      message: message,
    );
    final dedupeRef = firestore.collection(_dedupeCollection).doc(dedupeId);

    final isDuplicate = await firestore.runTransaction((tx) async {
      final existing = await tx.get(dedupeRef);
      if (existing.exists) {
        return true;
      }
      tx.set(dedupeRef, {
        'kind': 'manual_override',
        'created_at': Timestamp.now(),
        'target_zone': zoneTrim,
        'zone_slug': zoneSlug,
        'severity': severity,
        'admin_id': adminUid,
        'delivery': 'token_multicast',
        'status': 'pending',
        'message_preview': _preview(message),
      });
      return false;
    });

    if (isDuplicate) {
      return ZoneAlertSendResult(
        attempted: false,
        skippedDisabled: false,
        duplicate: true,
        rateLimited: false,
        dryRun: _dryRun,
        zoneSlug: zoneSlug,
        tokenCount: 0,
        successCount: 0,
        failureCount: 0,
        error: 'duplicate_within_window',
      );
    }

    try {
      final tokens = await _collectTokensForZone(firestore, zoneTrim);
      if (tokens.isEmpty) {
        try {
          await dedupeRef.delete();
        } catch (_) {}
        return ZoneAlertSendResult(
          attempted: false,
          skippedDisabled: false,
          duplicate: false,
          rateLimited: false,
          dryRun: _dryRun,
          zoneSlug: zoneSlug,
          tokenCount: 0,
          successCount: 0,
          failureCount: 0,
          error: 'no_device_tokens_for_zone',
        );
      }

      var success = 0;
      var failure = 0;
      const batchSize = 500;

      for (var i = 0; i < tokens.length; i += batchSize) {
        final end = math.min(i + batchSize, tokens.length);
        final batch = tokens.sublist(i, end);
        final mm = MulticastMessage(
          tokens: batch,
          notification: Notification(
            title: 'HydroAlert — $severity',
            body: message,
          ),
          data: {
            'type': 'manual_override',
            'severity': severity,
            'target_zone': zoneTrim,
            'message': _preview(message, maxLen: 180),
            'ts': DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
          },
        );
        final br = await messaging.sendEachForMulticast(mm, dryRun: _dryRun);
        success += br.successCount;
        failure += br.failureCount;
      }

      await rateRef.set({
        'last_sent_at': Timestamp.now(),
        'zone_slug': zoneSlug,
        'target_zone': zoneTrim,
        'last_severity': severity,
        'last_admin_id': adminUid,
        'last_token_count': tokens.length,
      });

      await dedupeRef.update({
        'status': _dryRun ? 'dry_run' : 'sent',
        'sent_at': Timestamp.now(),
        'token_count': tokens.length,
        'success_count': success,
        'failure_count': failure,
      });

      return ZoneAlertSendResult(
        attempted: true,
        skippedDisabled: false,
        duplicate: false,
        rateLimited: false,
        dryRun: _dryRun,
        zoneSlug: zoneSlug,
        tokenCount: tokens.length,
        successCount: success,
        failureCount: failure,
        error: failure > 0 && success == 0 ? 'all_multicast_batches_failed' : null,
      );
    } catch (e, _) {
      try {
        await dedupeRef.delete();
      } catch (_) {}
      return ZoneAlertSendResult(
        attempted: true,
        skippedDisabled: false,
        duplicate: false,
        rateLimited: false,
        dryRun: _dryRun,
        zoneSlug: zoneSlug,
        tokenCount: 0,
        successCount: 0,
        failureCount: 0,
        error: e.toString(),
      );
    }
  }

  static Future<List<String>> _collectTokensForZone(
    Firestore firestore,
    String zoneTrim,
  ) async {
    final query = firestore.collection(_usersCollection).whereFilter(
          Filter.and([
            Filter.where('is_active', WhereFilter.equal, true),
            Filter.where('location.zone', WhereFilter.equal, zoneTrim),
          ]),
        );
    final snap = await query.get();
    final out = <String>{};
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;
      final ut = (data['user_type'] as String?)?.trim().toLowerCase();
      if (!_includeAdminRecipients && ut == 'admin') continue;

      final raw = data['device_tokens'];
      if (raw is List) {
        for (final t in raw) {
          if (t is String && t.trim().isNotEmpty) {
            out.add(t.trim());
          }
        }
      }
    }
    return out.toList();
  }

  static String _dedupeId({
    required String zone,
    required String severity,
    required String message,
  }) {
    final bucket =
        DateTime.now().millisecondsSinceEpoch ~/ (_dedupeWindowSeconds * 1000);
    final raw = 'manual_override|$zone|$severity|$message|$bucket';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  static String _preview(String message, {int maxLen = 240}) {
    final t = message.trim();
    if (t.length <= maxLen) return t;
    return '${t.substring(0, maxLen)}…';
  }
}

class ZoneAlertSendResult {
  const ZoneAlertSendResult({
    required this.attempted,
    required this.skippedDisabled,
    required this.duplicate,
    required this.rateLimited,
    required this.dryRun,
    required this.zoneSlug,
    required this.tokenCount,
    required this.successCount,
    required this.failureCount,
    required this.error,
  });

  final bool attempted;
  final bool skippedDisabled;
  final bool duplicate;
  final bool rateLimited;
  final bool dryRun;
  final String zoneSlug;
  final int tokenCount;
  final int successCount;
  final int failureCount;
  final String? error;

  Map<String, dynamic> toLogMap() {
    return {
      'mode': 'token_multicast',
      'attempted': attempted,
      'skipped_disabled': skippedDisabled,
      'duplicate': duplicate,
      'rate_limited': rateLimited,
      'dry_run': dryRun,
      'zone_slug': zoneSlug,
      'token_count': tokenCount,
      'success_count': successCount,
      'failure_count': failureCount,
      if (error != null) 'error': error,
    };
  }
}
