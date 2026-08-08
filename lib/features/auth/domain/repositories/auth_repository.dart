import 'package:firebase_auth/firebase_auth.dart';

/// Contrat d'authentification (anonyme + admin email).
abstract class AuthRepository {
  Stream<User?> authStateChanges();

  User? get currentUser;

  bool get isAnonymous;

  Future<void> signInAsAdmin({
    required String email,
    required String password,
  });

  Future<void> signOutToAnonymous();

  /// True si l'utilisateur courant est administrateur.
  Future<bool> isCurrentUserAdmin();

  Stream<bool> watchIsAdmin();
}
