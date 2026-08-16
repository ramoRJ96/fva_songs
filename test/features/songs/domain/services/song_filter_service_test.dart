import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/services/song_filter_service.dart';

Song _song({
  required String id,
  required String number,
  required String title,
  String author = '',
  String theme = '',
  String key = '',
  SongLanguage language = SongLanguage.fr,
}) {
  return Song(
    id: id,
    title: title,
    number: number,
    author: author,
    theme: theme,
    key: key,
    language: language,
    firstLine: '',
    sections: const [],
  );
}

void main() {
  const service = SongFilterService();

  final alpha = _song(
    id: '1',
    number: '1',
    title: 'Alpha Song',
    author: 'John Doe',
    theme: 'Louange',
    key: 'C',
    language: SongLanguage.fr,
  );
  final beta = _song(
    id: '2',
    number: '2',
    title: 'Beta Alpha',
    author: 'Alpha John',
    theme: 'Joie',
    key: 'D',
    language: SongLanguage.mg,
  );
  final gamma = _song(
    id: '3',
    number: '42',
    title: 'Gamma',
    author: 'Someone Else',
    theme: 'Espoir',
    key: 'G',
    language: SongLanguage.fr,
  );

  final songs = [alpha, beta, gamma];

  group('query vide', () {
    test('scope all renvoie tous les chants sans reclasser', () {
      final result = service.filter(
        songs: songs,
        query: '',
        scope: SearchScope.all,
        favoriteIds: const {},
      );
      expect(result, songs);
      expect(identical(result, songs), isTrue);
    });

    test('scope favoris sans texte ne renvoie que les favoris', () {
      final result = service.filter(
        songs: songs,
        query: '',
        scope: SearchScope.favorites,
        favoriteIds: {beta.id},
      );
      expect(result, [beta]);
    });
  });

  group('match numéro exact', () {
    test('priorité maximale, peu importe le scope', () {
      final result = service.filter(
        songs: songs,
        query: '42',
        scope: SearchScope.all,
        favoriteIds: const {},
      );
      expect(result.first, gamma);
    });
  });

  group('scope title', () {
    test('titre qui commence par la query est classé avant "contains"', () {
      final result = service.filter(
        songs: songs,
        query: 'alpha',
        scope: SearchScope.title,
        favoriteIds: const {},
      );
      // "Alpha Song" starts with "alpha", "Beta Alpha" only contains it.
      expect(result, [alpha, beta]);
    });

    test('aucun match si le titre ne contient pas la query', () {
      final result = service.filter(
        songs: songs,
        query: 'zzz',
        scope: SearchScope.title,
        favoriteIds: const {},
      );
      expect(result, isEmpty);
    });
  });

  group('scope number', () {
    test('contains sur le numéro', () {
      final result = service.filter(
        songs: songs,
        query: '4',
        scope: SearchScope.number,
        favoriteIds: const {},
      );
      expect(result, [gamma]);
    });
  });

  group('scope author', () {
    test('classe "starts with" avant "contains"', () {
      final result = service.filter(
        songs: songs,
        query: 'alpha',
        scope: SearchScope.author,
        favoriteIds: const {},
      );
      // "Alpha John" commence par "alpha", "John Doe" ne matche pas.
      expect(result, [beta]);
    });
  });

  group('scope theme', () {
    test('filtre sur le thème normalisé', () {
      final result = service.filter(
        songs: songs,
        query: 'louange',
        scope: SearchScope.theme,
        favoriteIds: const {},
      );
      expect(result, [alpha]);
    });
  });

  group('scope key', () {
    test('filtre sur la tonalité', () {
      final result = service.filter(
        songs: songs,
        query: 'd',
        scope: SearchScope.key,
        favoriteIds: const {},
      );
      expect(result, [beta]);
    });
  });

  group('scope language', () {
    test('reconnaît le code langue', () {
      final result = service.filter(
        songs: songs,
        query: 'mg',
        scope: SearchScope.language,
        favoriteIds: const {},
      );
      expect(result, [beta]);
    });

    test('reconnaît les alias "francais" et "malagasy"', () {
      final fr = service.filter(
        songs: songs,
        query: 'francais',
        scope: SearchScope.language,
        favoriteIds: const {},
      );
      expect(fr, containsAll([alpha, gamma]));

      final mg = service.filter(
        songs: songs,
        query: 'malagasy',
        scope: SearchScope.language,
        favoriteIds: const {},
      );
      expect(mg, [beta]);
    });
  });

  group('scope favorites avec texte', () {
    test('restreint aux favoris ET au texte recherché', () {
      final result = service.filter(
        songs: songs,
        query: 'alpha',
        scope: SearchScope.favorites,
        favoriteIds: {beta.id, gamma.id},
      );
      // gamma ne matche pas "alpha", seul beta est favori + matche.
      expect(result, [beta]);
    });
  });

  group('accents et casse', () {
    test('la recherche est insensible aux accents et à la casse', () {
      final accented = _song(id: '4', number: '4', title: 'Déraiko Tompo Ô');
      final result = service.filter(
        songs: [accented],
        query: 'DERAIKO',
        scope: SearchScope.all,
        favoriteIds: const {},
      );
      expect(result, [accented]);
    });
  });
}
