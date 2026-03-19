import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firestore_system_logs_repository.dart';
import 'mock_system_logs_repository.dart';
import 'system_logs_repository.dart';

class SystemLogsRepositoryFactory {
  static SystemLogsRepository create({required bool firebaseReady}) {
    if (firebaseReady && Firebase.apps.isNotEmpty) {
      return FirestoreSystemLogsRepository(
        firestore: FirebaseFirestore.instance,
      );
    }

    return const MockSystemLogsRepository();
  }
}
