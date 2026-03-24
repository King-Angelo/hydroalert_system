// Lightweight load / soak probe for the API (no extra tools required).
//
// Usage (from `backend/api`):
//   dart run tool/qa_load_probe.dart
//
// Env:
//   QA_API_BASE          — default http://localhost:8080
//   QA_LOAD_PATH         — default /health
//   QA_LOAD_CONCURRENCY  — parallel requests per round (default 10)
//   QA_LOAD_ROUNDS       — number of rounds (default 20)
//
// Example staging:
//   set QA_API_BASE=https://your-api.onrender.com&& set QA_LOAD_PATH=/health/detailed&& dart run tool/qa_load_probe.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final base = (Platform.environment['QA_API_BASE'] ?? 'http://localhost:8080')
      .trim()
      .replaceAll(RegExp(r'/$'), '');
  final path = Platform.environment['QA_LOAD_PATH'] ?? '/health';
  final concurrency =
      int.tryParse(Platform.environment['QA_LOAD_CONCURRENCY'] ?? '') ?? 10;
  final rounds = int.tryParse(Platform.environment['QA_LOAD_ROUNDS'] ?? '') ?? 20;

  final uri = Uri.parse('$base$path');
  stdout.writeln('QA load probe → $uri');
  stdout.writeln('concurrency=$concurrency rounds=$rounds');

  final latenciesMs = <int>[];
  var failures = 0;

  final client = HttpClient();

  for (var r = 0; r < rounds; r++) {
    final wall = Stopwatch()..start();
    await Future.wait(
      List.generate(
        concurrency,
        (_) => _oneGet(client, uri, latenciesMs, () => failures++),
      ),
    );
    wall.stop();
    stdout.writeln(
      'round ${r + 1}/$rounds wall_ms=${wall.elapsedMilliseconds}',
    );
  }

  client.close(force: true);

  if (latenciesMs.isEmpty) {
    stderr.writeln(
      'No successful requests (failures=$failures). '
      'Check QA_API_BASE and that the API is running.',
    );
    exitCode = 1;
    return;
  }

  latenciesMs.sort();
  final p50 = latenciesMs[latenciesMs.length ~/ 2];
  final p95Idx = (latenciesMs.length * 0.95).floor().clamp(0, latenciesMs.length - 1);
  final p95 = latenciesMs[p95Idx];

  stdout.writeln(jsonEncode({
    'ok': true,
    'uri': uri.toString(),
    'samples': latenciesMs.length,
    'failures': failures,
    'latency_ms_p50': p50,
    'latency_ms_p95': p95,
    'latency_ms_max': latenciesMs.last,
  }));
}

Future<void> _oneGet(
  HttpClient client,
  Uri uri,
  List<int> latenciesMs,
  void Function() onFailure,
) async {
  final sw = Stopwatch()..start();
  try {
    final req = await client.getUrl(uri);
    final resp = await req.close().timeout(const Duration(seconds: 30));
    await resp.drain();
    sw.stop();
    if (resp.statusCode >= 200 && resp.statusCode < 400) {
      latenciesMs.add(sw.elapsedMilliseconds);
    } else {
      onFailure();
    }
  } on Object catch (_) {
    sw.stop();
    onFailure();
  }
}
