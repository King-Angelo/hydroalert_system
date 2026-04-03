// Smoke checks for privileged v1 routes (no extra deps; uses dart:io).
//
// Tier 1 (default): verifies GET /health/detailed and that each v1 POST
// returns 401 without Authorization (proves routes exist behind admin auth).
//
// Tier 2 (optional): set SMOKE_FIREBASE_ID_TOKEN to a valid Firebase **admin**
// ID token; script sends safe payloads with synthetic IDs expecting **404**
// (proves auth + handler wiring; does not mutate real documents).
//
// Usage (from `backend/api`):
//   dart run tool/v1_admin_route_smoke.dart
//
// Env:
//   SMOKE_API_BASE            — default http://localhost:8080 (no trailing slash)
//   SMOKE_FIREBASE_ID_TOKEN — optional; Bearer token for tier-2 checks
//
// Staging example:
//   set SMOKE_API_BASE=https://your-api.onrender.com
//   set SMOKE_FIREBASE_ID_TOKEN=<paste token from signed-in admin web session>
//   dart run tool/v1_admin_route_smoke.dart

import 'dart:convert';
import 'dart:io';

/// Unlikely to collide with real Firestore document IDs.
const _syntheticId = '__smoke_v1_probe_nonexistent_doc__';

Future<void> main(List<String> args) async {
  final base = (Platform.environment['SMOKE_API_BASE'] ?? 'http://localhost:8080')
      .trim()
      .replaceAll(RegExp(r'/$'), '');
  final token = Platform.environment['SMOKE_FIREBASE_ID_TOKEN']?.trim();
  final runAuth = token != null && token.isNotEmpty;

  stdout.writeln('v1 admin route smoke → $base');
  stdout.writeln('tier=${runAuth ? "2 (Bearer token + 404 probes)" : "1 (401 only)"}');

  final client = HttpClient();
  var failed = false;

  Future<void> check(String name, Future<bool> Function() fn) async {
    final ok = await fn();
    stdout.writeln(ok ? '  ✓ $name' : '  ✗ $name');
    if (!ok) failed = true;
  }

  await check('GET /health/detailed (200)', () async {
    final code = await _getStatus(client, Uri.parse('$base/health/detailed'));
    return code == 200;
  });

  final v1Posts = <String, String>{
    '/v1/reports/review': jsonEncode({
      'reportId': _syntheticId,
      'decision': 'validated',
      'reviewNotes': '',
    }),
    '/v1/users/update-role':
        jsonEncode({'targetUserId': _syntheticId, 'nextRole': 'resident'}),
    '/v1/users/set-active-state':
        jsonEncode({'targetUserId': _syntheticId, 'isActive': false}),
    '/v1/users/soft-delete': jsonEncode({'targetUserId': _syntheticId}),
    '/v1/shelters/update-status':
        jsonEncode({'shelterId': _syntheticId, 'nextStatus': 'Open'}),
    '/v1/shelters/update-capacity':
        jsonEncode({'shelterId': _syntheticId, 'nextCapacity': 0}),
    '/v1/shelters/update-occupancy':
        jsonEncode({'shelterId': _syntheticId, 'nextOccupancy': 0}),
    '/v1/shelters/soft-delete': jsonEncode({'shelterId': _syntheticId}),
  };

  for (final e in v1Posts.entries) {
    await check('POST ${e.key} without auth → 401', () async {
      final code = await _postJson(
        client,
        Uri.parse('$base${e.key}'),
        body: e.value,
        bearer: null,
      );
      return code == 401;
    });
  }

  // POST /v1/alerts/manual-override can trigger FCM — only assert 401 without token.
  await check('POST /v1/alerts/manual-override without auth → 401', () async {
    final code = await _postJson(
      client,
      Uri.parse('$base/v1/alerts/manual-override'),
      body: jsonEncode({
        'severity': 'Advisory',
        'message': 'smoke',
        'targetZone': 'Zone-A',
      }),
      bearer: null,
    );
    return code == 401;
  });

  if (runAuth) {
    for (final e in v1Posts.entries) {
      await check('POST ${e.key} with auth → 404 (synthetic id)', () async {
        final code = await _postJson(
          client,
          Uri.parse('$base${e.key}'),
          body: e.value,
          bearer: token,
        );
        return code == 404;
      });
    }
  } else {
    stdout.writeln(
      '  … tier-2 skipped (set SMOKE_FIREBASE_ID_TOKEN for auth probes)',
    );
  }

  client.close(force: true);

  if (failed) {
    stderr.writeln('Smoke FAILED');
    exitCode = 1;
  } else {
    stdout.writeln('Smoke OK');
  }
}

Future<int> _getStatus(HttpClient client, Uri uri) async {
  try {
    final req = await client.getUrl(uri);
    final res = await req.close();
    res.drain<void>();
    return res.statusCode;
  } catch (_) {
    return -1;
  }
}

Future<int> _postJson(
  HttpClient client,
  Uri uri, {
  required String body,
  String? bearer,
}) async {
  try {
    final req = await client.postUrl(uri);
    req.headers.contentType = ContentType.json;
    if (bearer != null && bearer.isNotEmpty) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
    }
    req.write(body);
    final res = await req.close();
    await res.drain<void>();
    return res.statusCode;
  } catch (_) {
    return -1;
  }
}
