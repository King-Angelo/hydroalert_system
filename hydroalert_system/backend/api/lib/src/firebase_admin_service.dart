import 'dart:io';

import 'package:dart_firebase_admin_plus/auth.dart';
import 'package:dart_firebase_admin_plus/dart_firebase_admin.dart';
import 'package:dart_firebase_admin_plus/firestore.dart';
import 'package:dart_firebase_admin_plus/messaging.dart';

/// Lazy-initialized Firebase Admin service for token verification and admin checks.
class FirebaseAdminService {
  FirebaseAdminService._();

  static FirebaseAdminService? _instance;
  static FirebaseAdminService get instance =>
      _instance ??= FirebaseAdminService._();

  FirebaseAdminApp? _app;
  Auth? _auth;
  Firestore? _firestore;
  Messaging? _messaging;

  static const _usersCollection = 'Users';

  /// Project ID for Firebase (e.g. hydroalert-dev).
  /// Set via FIREBASE_PROJECT_ID env var, defaults to hydroalert-dev.
  static String get projectId =>
      Platform.environment['FIREBASE_PROJECT_ID'] ?? 'hydroalert-dev';

  /// Path to service account JSON. Uses GOOGLE_APPLICATION_CREDENTIALS
  /// when set; otherwise returns null (ADC may use gcloud or metadata).
  static String? get _serviceAccountPath =>
      Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

  /// Ensures Firebase Admin is initialized. Call before verifyAndGetAdminUid.
  Future<void> ensureInitialized() async {
    if (_app != null) return;

    Credential credential;
    if (_serviceAccountPath != null && _serviceAccountPath!.isNotEmpty) {
      final file = File(_serviceAccountPath!);
      if (!await file.exists()) {
        throw StateError(
          'GOOGLE_APPLICATION_CREDENTIALS file not found: $_serviceAccountPath',
        );
      }
      credential = Credential.fromServiceAccount(file);
    } else {
      credential = Credential.fromApplicationDefaultCredentials();
    }

    _app = FirebaseAdminApp.initializeApp(projectId, credential);
    _auth = Auth(_app!);
    _firestore = Firestore(_app!);
  }

  /// Verifies the Firebase ID token and checks that the user is an active admin
  /// in Firestore Users/{uid}. Returns the verified admin UID or null.
  ///
  /// - [idToken] Raw Firebase ID token string (e.g. from Authorization: Bearer)
  /// - Returns uid if token is valid and Users/{uid} has user_type=='admin' and is_active==true
  Future<String?> verifyAndGetAdminUid(String idToken) async {
    await ensureInitialized();

    final decoded = await _auth!.verifyIdToken(idToken);
    final uid = decoded.uid;
    if (uid.isEmpty) return null;

    final isAdmin = await _isAdminInFirestore(uid);
    return isAdmin ? uid : null;
  }

  /// Firestore instance for admin operations (e.g. cron retention). Call after ensureInitialized.
  Future<Firestore> getFirestore() async {
    await ensureInitialized();
    return _firestore!;
  }

  /// FCM Admin API (topic / token messages). Call after [ensureInitialized].
  Future<Messaging> getMessaging() async {
    await ensureInitialized();
    return _messaging ??= Messaging(_app!);
  }

  Future<bool> _isAdminInFirestore(String uid) async {
    final docRef = _firestore!.collection(_usersCollection).doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return false;

    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) return false;

    final userType = (data['user_type'] as String?)?.trim().toLowerCase();
    final isActive = data['is_active'] == true;
    return userType == 'admin' && isActive;
  }
}
