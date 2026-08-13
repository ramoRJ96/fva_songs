import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/data/models/song_model.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';

void main() {
  group('SongModel.fromFirestore', () {
    test('parse tous les champs et sections', () {
      final model = SongModel.fromFirestore('doc-1', {
        'title': 'Mon Titre',
        'number': '12',
        'author': 'Auteur',
        'theme': 'Thème',
        'key': 'D',
        'language': 'mg',
        'firstLine': 'Première ligne',
        'searchText': 'deja normalise',
        'status': 'pending',
        'sections': [
          {
            'type': 'couplet',
            'index': 1,
            'lines': ['Ligne 1', 'Ligne 2'],
            'isBis': false,
          },
          {
            'type': 'refrain',
            'lines': ['Refrain'],
            'isBis': true,
          },
        ],
      });

      final song = model.song;
      expect(song.id, 'doc-1');
      expect(song.title, 'Mon Titre');
      expect(song.number, '12');
      expect(song.author, 'Auteur');
      expect(song.theme, 'Thème');
      expect(song.key, 'D');
      expect(song.language, SongLanguage.mg);
      expect(song.firstLine, 'Première ligne');
      expect(song.searchText, 'deja normalise');
      expect(song.status, SongStatus.pending);
      expect(song.sections, hasLength(2));
      expect(song.sections[0].type, SectionType.couplet);
      expect(song.sections[0].index, 1);
      expect(song.sections[0].lines, ['Ligne 1', 'Ligne 2']);
      expect(song.sections[0].isBis, isFalse);
      expect(song.sections[1].type, SectionType.refrain);
      expect(song.sections[1].index, isNull);
      expect(song.sections[1].isBis, isTrue);
    });

    test('applique des valeurs par défaut si champs absents', () {
      final model = SongModel.fromFirestore('doc-2', const {});
      final song = model.song;

      expect(song.id, 'doc-2');
      expect(song.title, '');
      expect(song.number, '');
      expect(song.author, '');
      expect(song.theme, '');
      expect(song.key, '');
      expect(song.language, SongLanguage.fr);
      expect(song.firstLine, '');
      expect(song.searchText, '');
      expect(song.status, SongStatus.approved);
      expect(song.sections, isEmpty);
    });

    test('type de section inconnu retombe sur couplet', () {
      final model = SongModel.fromFirestore('doc-3', {
        'sections': [
          {'type': 'sometype-inconnu', 'lines': <String>[]},
        ],
      });
      expect(model.song.sections.single.type, SectionType.couplet);
    });

    test('type chorus est reconnu', () {
      final model = SongModel.fromFirestore('doc-4', {
        'sections': [
          {'type': 'chorus', 'lines': <String>[]},
        ],
      });
      expect(model.song.sections.single.type, SectionType.chorus);
    });
  });

  group('SongModel.toFirestore', () {
    test('sérialise tous les champs attendus', () {
      const song = Song(
        id: 'ignored-in-map',
        title: 'Titre',
        number: '7',
        author: 'Auteur',
        theme: 'Thème',
        key: 'C',
        language: SongLanguage.mg,
        firstLine: 'Première ligne',
        sections: [
          LyricSection(type: SectionType.couplet, index: 1, lines: ['A', 'B']),
        ],
        searchText: 'deja normalise',
        status: SongStatus.pending,
      );

      final map = SongModel(song).toFirestore();

      expect(map['title'], 'Titre');
      expect(map['number'], '7');
      expect(map['author'], 'Auteur');
      expect(map['theme'], 'Thème');
      expect(map['key'], 'C');
      expect(map['language'], 'mg');
      expect(map['firstLine'], 'Première ligne');
      expect(map['status'], 'pending');
      expect(map['searchText'], 'deja normalise');
      expect(map['sections'], [
        {
          'type': 'couplet',
          'index': 1,
          'lines': ['A', 'B'],
          'isBis': false,
        },
      ]);
      expect(map['updatedAt'], isA<String>());
      // Pas de champ "id" dans le document (id = clé du document Firestore).
      expect(map.containsKey('id'), isFalse);
    });

    test('recalcule searchText quand il est vide', () {
      const song = Song(
        id: '',
        title: 'Alléluia',
        number: '3',
        author: '',
        theme: '',
        key: '',
        language: SongLanguage.fr,
        firstLine: '',
        sections: [],
      );

      final map = SongModel(song).toFirestore();
      expect(map['searchText'], SongModel.buildSearchText(song));
      expect(map['searchText'], contains('alleluia'));
    });
  });

  group('SongModel.buildSearchText', () {
    test('normalise et concatène tous les champs textuels', () {
      const song = Song(
        id: '',
        title: 'Déraiko Ô',
        number: '5',
        author: 'Jean',
        theme: 'Louange',
        key: 'G',
        language: SongLanguage.fr,
        firstLine: 'Première',
        sections: [
          LyricSection(type: SectionType.couplet, index: 1, lines: ['Ligne A']),
          LyricSection(type: SectionType.refrain, lines: ['Ligne B']),
        ],
      );

      final searchText = SongModel.buildSearchText(song);

      expect(searchText, contains('deraiko o'));
      expect(searchText, contains('jean'));
      expect(searchText, contains('louange'));
      expect(searchText, contains('ligne a'));
      expect(searchText, contains('ligne b'));
      // Tout en minuscule, sans accents.
      expect(searchText, searchText.toLowerCase());
    });
  });
}
