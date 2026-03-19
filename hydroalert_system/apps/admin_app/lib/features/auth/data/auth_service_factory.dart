import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth_service.dart';
import 'firebase_auth_service.dart';
import 'mock_auth_service.dart';

class AuthServiceFactory {
  static AuthService create({required bool firebaseReady}) {
    if (firebaseReady && Firebase.apps.isNotEmpty) {
      return FirebaseAuthService(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      );
    }

    return const MockAuthService();
  }
}
