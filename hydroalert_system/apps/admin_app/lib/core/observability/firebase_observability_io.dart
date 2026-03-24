import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Mobile/desktop: Analytics + Crashlytics (Firebase Spark).
Future<void> setupFirebaseObservabilityImpl() async {
  try {
    await FirebaseAnalytics.instance.logEvent(name: 'admin_app_start');

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e, st) {
    debugPrint('Firebase observability (io) skipped: $e\n$st');
  }
}
