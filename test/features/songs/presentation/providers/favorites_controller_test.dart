import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fva_songs/features/songs/domain/repositories/favorite_repository.dart';
import 'package:fva_songs/features/songs/presentation/providers/songs_providers.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockFavoriteRepository repository;
  late FavoritesController controller;

  setUp(() {
    repository = MockFavoriteRepository();
    controller = FavoritesController(repository);
  });

  test('toggle délègue au repository avec le bon état courant', () async {
    when(
      () => repository.toggleFavorite('song-1', currentlyFavorite: true),
    ).thenAnswer((_) async {});

    await controller.toggle('song-1', currentlyFavorite: true);

    verify(
      () => repository.toggleFavorite('song-1', currentlyFavorite: true),
    ).called(1);
  });
}
