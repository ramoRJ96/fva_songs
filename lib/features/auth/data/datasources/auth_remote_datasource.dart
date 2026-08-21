import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Accès Firebase Auth + vérification du rôle admin.
///
/// Un admin est reconnu si :
/// - un document `admins/{uid}` existe, ou
/// - son e-mail figure dans `config/admins.emails`.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOutToAnonymous() async {
    await _auth.signOut();
    await _auth.signInAnonymously();
  }

  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    return _isAdminUser(user);
  }

  Stream<bool> watchIsAdmin() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null || user.isAnonymous) return false;
      return _isAdminUser(user);
    });
  }

  Future<bool> _isAdminUser(User user) async {
    final uidDoc = await _firestore.collection('admins').doc(user.uid).get();
    if (uidDoc.exists) return true;

    final email = user.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return false;

    try {
      final config = await _firestore.collection('config').doc('admins').get();
      final emails = (config.data()?['emails'] as List<dynamic>? ?? const [])
          .map((e) => e.toString().trim().toLowerCase())
          .toList();
      return emails.contains(email);
    } catch (_) {
      return false;
    }
  }
}
