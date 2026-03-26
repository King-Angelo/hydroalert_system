import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

/// Resident-facing app (stub). Alerting P0 is **admin API + token multicast**; token
/// registration for end users can live here later — not required for manual-override flow.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ResidentApp());
}

class ResidentApp extends StatelessWidget {
  const ResidentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroAlert Resident',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const _PlaceholderHome(),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HydroAlert Resident')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Stub: build auth, profile, and FCM token → Firestore device_tokens when ready.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
