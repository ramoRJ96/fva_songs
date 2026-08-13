import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/services/song_filter_service.dart';
import 'package:fva_songs/features/songs/presentation/providers/songs_providers.dart';

Song _song(String id, String number) {
  return Song(
    id: id,
    title: 'Titre $id',
    number: number,
    author: '',
    theme: '',
    key: '',
    language: SongLanguage.fr,
    firstLine: '',
    sections: const [],
  );
}

void main() {
  late ProviderContainer container;
  final songA = _song('a', '1');
  final songB = _song('b', '2');
  final songC = _song('c', '3');

  ProviderContainer buildContainer({
    required List<Song> songs,
    required Set<String> favoriteIds,
  }) {
    return ProviderContainer(
      overrides: [
        songsCatalogProvider.overrideWith((ref) => Stream.value(songs)),
        favoriteIdsProvider.overrideWith((ref) => Stream.value(favoriteIds)),
      ],
    );
  }

  tearDown(() => container.dispose());

  test('favoriteSongsProvider = intersection catalogue ∩ favoris', () async {
    container = buildContainer(
      songs: [songA, songB, songC],
      favoriteIds: {'b', 'c'},
    );

    await container.read(songsCatalogProvider.future);
    await container.read(favoriteIdsProvider.future);

    final favorites = container.read(favoriteSongsProvider);
    expect(favorites, [songB, songC]);
  });

  test('isFavoriteProvider reflète l\'ensemble des favoris', () async {
    container = buildContainer(songs: [songA, songB], favoriteIds: {'a'});

    await container.read(favoriteIdsProvider.future);

    expect(container.read(isFavoriteProvider('a')), isTrue);
    expect(container.read(isFavoriteProvider('b')), isFalse);
  });

  test('songByIdProvider retrouve un chant dans le catalogue', () async {
    container = buildContainer(songs: [songA, songB], favoriteIds: const {});

    await container.read(songsCatalogProvider.future);

    expect(container.read(songByIdProvider('b')), songB);
    expect(container.read(songByIdProvider('inconnu')), isNull);
  });

  test(
    'filteredSongsProvider applique la recherche et le scope courants',
    () async {
      container = buildContainer(
        songs: [songA, songB, songC],
        favoriteIds: const {},
      );

      await container.read(songsCatalogProvider.future);
      await container.read(favoriteIdsProvider.future);

      container.read(searchQueryProvider.notifier).state = '2';
      container.read(searchScopeProvider.notifier).state = SearchScope.number;

      final result = container.read(filteredSongsProvider);
      expect(result, [songB]);
    },
  );

  test(
    'filteredSongsProvider renvoie tout le catalogue sans recherche',
    () async {
      container = buildContainer(
        songs: [songA, songB, songC],
        favoriteIds: const {},
      );

      await container.read(songsCatalogProvider.future);
      await container.read(favoriteIdsProvider.future);

      final result = container.read(filteredSongsProvider);
      expect(result, [songA, songB, songC]);
    },
  );
}
