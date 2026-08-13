import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fva_songs/features/auth/domain/repositories/auth_repository.dart';
import 'package:fva_songs/features/auth/presentation/providers/auth_providers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late AdminAuthController controller;

  setUp(() {
    repository = MockAuthRepository();
    controller = AdminAuthController(repository);
  });

  test('signIn délègue signInAsAdmin au repository', () async {
    when(
      () =>
          repository.signInAsAdmin(email: 'admin@mail.com', password: 'secret'),
    ).thenAnswer((_) async {});

    await controller.signIn(email: 'admin@mail.com', password: 'secret');

    verify(
      () =>
          repository.signInAsAdmin(email: 'admin@mail.com', password: 'secret'),
    ).called(1);
  });

  test('signOut délègue signOutToAnonymous au repository', () async {
    when(() => repository.signOutToAnonymous()).thenAnswer((_) async {});

    await controller.signOut();

    verify(() => repository.signOutToAnonymous()).called(1);
  });
}
