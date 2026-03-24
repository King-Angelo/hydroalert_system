import 'package:flutter/foundation.dart';

import 'firebase_observability_io.dart'
    if (dart.library.html) 'firebase_observability_web.dart';

/// Firebase Spark-tier observability entrypoint.
Future<void> setupFirebaseObservability() async {
  try {
    await setupFirebaseObservabilityImpl();
  } catch (e, st) {
    debugPrint('setupFirebaseObservability: $e\n$st');
  }
}
