import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_client.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// True lorsque l'utilisateur connecté a le rôle administrateur.
final isAdminProvider = StreamProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).watchIsAdmin();
});

final adminAuthControllerProvider = Provider<AdminAuthController>((ref) {
  return AdminAuthController(
    ref.watch(authRepositoryProvider),
    analytics: ref.watch(analyticsClientProvider),
  );
});

class AdminAuthController {
  AdminAuthController(
    this._repository, {
    AnalyticsClient analytics = const NoOpAnalyticsClient(),
  }) : _analytics = analytics;

  final AuthRepository _repository;
  final AnalyticsClient _analytics;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _repository.signInAsAdmin(email: email, password: password);
    await _analytics.logEvent(AnalyticsEvents.adminAuthSignIn);
  }

  Future<void> signOut() async {
    await _repository.signOutToAnonymous();
    await _analytics.logEvent(AnalyticsEvents.adminAuthSignOut);
  }
}
