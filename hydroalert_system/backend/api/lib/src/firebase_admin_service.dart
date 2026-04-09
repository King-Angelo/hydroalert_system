import 'dart:convert';
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
      await _repairServiceAccountJsonFileIfNeeded(file);
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

  /// If [FIREBASE_SERVICE_ACCOUNT_JSON] was pasted with literal newlines inside
  /// `private_key`, JSON is invalid (`FormatException: Control character in string`).
  /// Rewrites the file with a valid PEM string (escaped `\n` only).
  static Future<void> _repairServiceAccountJsonFileIfNeeded(File file) async {
    var raw = await file.readAsString();
    if (raw.startsWith('\uFEFF')) {
      raw = raw.substring(1);
    }
    try {
      jsonDecode(raw);
      return;
    } on FormatException {
      // try repair below
    }
    final repaired = _repairServiceAccountJsonString(raw);
    if (repaired == null) {
      throw FormatException(
        'Invalid service account JSON (could not parse or repair private_key). '
        'Use minified JSON or FIREBASE_SERVICE_ACCOUNT_JSON_B64 — see DEPLOY_RENDER.md.',
      );
    }
    await file.writeAsString(repaired);
  }

  /// Returns null if the PEM block could not be located or repaired JSON is invalid.
  static String? _repairServiceAccountJsonString(String raw) {
    var s = raw;
    if (s.contains('\r')) {
      s = s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    }
    try {
      jsonDecode(s);
      return s;
    } on FormatException {
      // continue
    }

    final keyPattern = RegExp(r'"private_key"\s*:\s*"');
    final match = keyPattern.firstMatch(s);
    if (match == null) return null;

    final valueStart = match.end;
    final markers = [
      (
        begin: '-----BEGIN PRIVATE KEY-----',
        end: '-----END PRIVATE KEY-----',
      ),
      (
        begin: '-----BEGIN RSA PRIVATE KEY-----',
        end: '-----END RSA PRIVATE KEY-----',
      ),
    ];
    for (final m in markers) {
      final pemBeginIdx = s.indexOf(m.begin, valueStart);
      if (pemBeginIdx < 0) continue;
      final pemEndIdx = s.indexOf(m.end, pemBeginIdx);
      if (pemEndIdx < 0) continue;
      final afterEnd = pemEndIdx + m.end.length;
      var closeIdx = afterEnd;
      while (closeIdx < s.length && s[closeIdx] != '"') {
        closeIdx++;
      }
      if (closeIdx >= s.length) return null;
      final pemInner = s.substring(pemBeginIdx, afterEnd);
      final suffix = s.substring(closeIdx + 1);
      final repaired =
          '${s.substring(0, match.start)}"private_key": ${jsonEncode(pemInner)}$suffix';
      try {
        jsonDecode(repaired);
        return repaired;
      } on FormatException {
        return null;
      }
    }
    return null;
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
