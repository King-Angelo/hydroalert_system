import 'package:firebase_analytics/firebase_analytics.dart';

/// Web: Analytics only (Crashlytics not used on web for P1).
Future<void> setupFirebaseObservabilityImpl() async {
  await FirebaseAnalytics.instance.logEvent(name: 'admin_app_start');
}
