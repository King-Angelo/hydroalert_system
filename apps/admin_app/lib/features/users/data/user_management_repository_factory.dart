import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firestore_user_management_repository.dart';
import 'mock_user_management_repository.dart';
import 'user_management_repository.dart';

class UserManagementRepositoryFactory {
  static UserManagementRepository create({required bool firebaseReady}) {
    if (firebaseReady && Firebase.apps.isNotEmpty) {
      return FirestoreUserManagementRepository(
        firestore: FirebaseFirestore.instance,
      );
    }

    return const MockUserManagementRepository();
  }
}
