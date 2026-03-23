import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const _usersCollection = 'Users';

  @override
  Future<AuthSignInResult> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        await _auth.signOut();
        return const AuthSignInResult.failure(errorCode: 'auth-no-user');
      }

      final adminAllowed = await _isAdminAllowed(uid);
      if (!adminAllowed) {
        await _auth.signOut();
        return const AuthSignInResult.failure(errorCode: 'auth-not-admin');
      }

      return AuthSignInResult.success(adminUserId: uid);
    } on FirebaseAuthException catch (error) {
      return AuthSignInResult.failure(
        errorCode: error.code,
      );
    } catch (_) {
      return const AuthSignInResult.failure(errorCode: 'auth-unknown');
    }
  }

  @override
  Future<String?> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (error) {
      return error.code;
    } catch (_) {
      return 'auth-unknown';
    }
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<String?> getCurrentAdminUserId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final adminAllowed = await _isAdminAllowed(uid);
    if (!adminAllowed) return null;
    return uid;
  }

  @override
  Future<String?> getIdToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final adminAllowed = await _isAdminAllowed(uid);
    if (!adminAllowed) return null;
    return _auth.currentUser?.getIdToken();
  }

  Future<bool> _isAdminAllowed(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;

    final userType = (data['user_type'] as String?)?.trim().toLowerCase();
    final isActive = data['is_active'] == true;
    return userType == 'admin' && isActive;
  }
}
