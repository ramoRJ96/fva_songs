import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fva_songs/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fva_songs/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class FakeUser extends Fake implements User {}

void main() {
  late MockAuthRemoteDataSource remote;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remote);
  });

  test('authStateChanges délègue à la datasource', () {
    final stream = Stream<User?>.value(null);
    when(() => remote.authStateChanges()).thenAnswer((_) => stream);

    expect(repository.authStateChanges(), stream);
  });

  test('currentUser délègue à la datasource', () {
    final user = FakeUser();
    when(() => remote.currentUser).thenReturn(user);

    expect(repository.currentUser, user);
  });

  test('isAnonymous délègue à la datasource', () {
    when(() => remote.isAnonymous).thenReturn(true);
    expect(repository.isAnonymous, isTrue);

    when(() => remote.isAnonymous).thenReturn(false);
    expect(repository.isAnonymous, isFalse);
  });

  test('signInAsAdmin délègue à la datasource', () async {
    when(
      () => remote.signInWithEmail(email: 'admin@mail.com', password: 'secret'),
    ).thenAnswer((_) async {});

    await repository.signInAsAdmin(email: 'admin@mail.com', password: 'secret');

    verify(
      () => remote.signInWithEmail(email: 'admin@mail.com', password: 'secret'),
    ).called(1);
  });

  test('signOutToAnonymous délègue à la datasource', () async {
    when(() => remote.signOutToAnonymous()).thenAnswer((_) async {});

    await repository.signOutToAnonymous();

    verify(() => remote.signOutToAnonymous()).called(1);
  });

  test('isCurrentUserAdmin délègue à la datasource', () async {
    when(() => remote.isCurrentUserAdmin()).thenAnswer((_) async => true);

    expect(await repository.isCurrentUserAdmin(), isTrue);
  });

  test('watchIsAdmin délègue à la datasource', () {
    final stream = Stream<bool>.value(true);
    when(() => remote.watchIsAdmin()).thenAnswer((_) => stream);

    expect(repository.watchIsAdmin(), stream);
  });
}
