import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<User?> authStateChanges() => _remote.authStateChanges();

  @override
  User? get currentUser => _remote.currentUser;

  @override
  bool get isAnonymous => _remote.isAnonymous;

  @override
  Future<void> signInAsAdmin({
    required String email,
    required String password,
  }) {
    return _remote.signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> signOutToAnonymous() => _remote.signOutToAnonymous();

  @override
  Future<bool> isCurrentUserAdmin() => _remote.isCurrentUserAdmin();

  @override
  Stream<bool> watchIsAdmin() => _remote.watchIsAdmin();
}
