import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fva_songs/features/songs/data/datasources/favorite_remote_datasource.dart';
import 'package:fva_songs/features/songs/data/repositories/favorite_repository_impl.dart';

class MockFavoriteRemoteDataSource extends Mock
    implements FavoriteRemoteDataSource {}

void main() {
  late MockFavoriteRemoteDataSource remote;
  late FavoriteRepositoryImpl repository;

  setUp(() {
    remote = MockFavoriteRemoteDataSource();
    repository = FavoriteRepositoryImpl(remote);
  });

  test('watchFavoriteIds délègue à la datasource', () {
    final stream = Stream<Set<String>>.value({'1', '2'});
    when(() => remote.watchFavoriteIds()).thenAnswer((_) => stream);

    expect(repository.watchFavoriteIds(), stream);
  });

  test('addFavorite délègue à la datasource', () async {
    when(() => remote.addFavorite('song-1')).thenAnswer((_) async {});

    await repository.addFavorite('song-1');

    verify(() => remote.addFavorite('song-1')).called(1);
  });

  test('removeFavorite délègue à la datasource', () async {
    when(() => remote.removeFavorite('song-1')).thenAnswer((_) async {});

    await repository.removeFavorite('song-1');

    verify(() => remote.removeFavorite('song-1')).called(1);
  });

  group('toggleFavorite', () {
    test('supprime si déjà favori', () async {
      when(() => remote.removeFavorite('song-1')).thenAnswer((_) async {});

      await repository.toggleFavorite('song-1', currentlyFavorite: true);

      verify(() => remote.removeFavorite('song-1')).called(1);
      verifyNever(() => remote.addFavorite(any()));
    });

    test('ajoute si pas encore favori', () async {
      when(() => remote.addFavorite('song-1')).thenAnswer((_) async {});

      await repository.toggleFavorite('song-1', currentlyFavorite: false);

      verify(() => remote.addFavorite('song-1')).called(1);
      verifyNever(() => remote.removeFavorite(any()));
    });
  });
}
