import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';

Song _song({List<LyricSection> sections = const []}) {
  return Song(
    id: 'id-1',
    title: 'Titre',
    number: '42',
    author: 'Auteur',
    theme: 'Thème',
    key: 'G',
    language: SongLanguage.fr,
    firstLine: 'Première ligne',
    sections: sections,
  );
}

void main() {
  group('SongLanguage.fromCode', () {
    test('reconnaît "mg"', () {
      expect(SongLanguage.fromCode('mg'), SongLanguage.mg);
    });

    test('retombe sur fr pour tout autre code (y compris null)', () {
      expect(SongLanguage.fromCode('fr'), SongLanguage.fr);
      expect(SongLanguage.fromCode(null), SongLanguage.fr);
      expect(SongLanguage.fromCode('en'), SongLanguage.fr);
    });
  });

  group('SongStatus.fromString', () {
    test('reconnaît "pending"', () {
      expect(SongStatus.fromString('pending'), SongStatus.pending);
    });

    test('retombe sur approved par défaut (migration douce)', () {
      expect(SongStatus.fromString('approved'), SongStatus.approved);
      expect(SongStatus.fromString(null), SongStatus.approved);
      expect(SongStatus.fromString('unknown'), SongStatus.approved);
    });
  });

  group('Song.copyWith', () {
    test('ne change rien si aucun paramètre fourni', () {
      final song = _song();
      final copy = song.copyWith();

      expect(copy.id, song.id);
      expect(copy.title, song.title);
      expect(copy.number, song.number);
      expect(copy.author, song.author);
      expect(copy.theme, song.theme);
      expect(copy.key, song.key);
      expect(copy.language, song.language);
      expect(copy.firstLine, song.firstLine);
      expect(copy.sections, song.sections);
      expect(copy.searchText, song.searchText);
      expect(copy.status, song.status);
    });

    test('remplace uniquement les champs fournis', () {
      final song = _song();
      final copy = song.copyWith(id: 'new-id', status: SongStatus.pending);

      expect(copy.id, 'new-id');
      expect(copy.status, SongStatus.pending);
      // Le reste est inchangé.
      expect(copy.title, song.title);
      expect(copy.number, song.number);
    });
  });

  group('Song.sectionsForDisplay', () {
    test('renvoie les sections telles quelles sans couplet', () {
      final sections = [
        const LyricSection(type: SectionType.refrain, lines: ['Ref 1']),
      ];
      final song = _song(sections: sections);

      expect(song.sectionsForDisplay, sections);
    });

    test('renvoie les sections telles quelles sans refrain/chorus', () {
      final sections = [
        const LyricSection(
          type: SectionType.couplet,
          index: 1,
          lines: ['Couplet 1'],
        ),
        const LyricSection(
          type: SectionType.couplet,
          index: 2,
          lines: ['Couplet 2'],
        ),
      ];
      final song = _song(sections: sections);

      expect(song.sectionsForDisplay, sections);
    });

    test('déplace un refrain final juste après le 1er couplet', () {
      final couplet1 = const LyricSection(
        type: SectionType.couplet,
        index: 1,
        lines: ['Couplet 1'],
      );
      final couplet2 = const LyricSection(
        type: SectionType.couplet,
        index: 2,
        lines: ['Couplet 2'],
      );
      final couplet3 = const LyricSection(
        type: SectionType.couplet,
        index: 3,
        lines: ['Couplet 3'],
      );
      final refrain = const LyricSection(
        type: SectionType.refrain,
        lines: ['Refrain'],
      );
      final song = _song(sections: [couplet1, couplet2, couplet3, refrain]);

      expect(song.sectionsForDisplay, [couplet1, refrain, couplet2, couplet3]);
    });

    test('déplace un refrain déjà présent avant le 1er couplet', () {
      final refrain = const LyricSection(
        type: SectionType.refrain,
        lines: ['Refrain intro'],
      );
      final couplet1 = const LyricSection(
        type: SectionType.couplet,
        index: 1,
        lines: ['Couplet 1'],
      );
      final couplet2 = const LyricSection(
        type: SectionType.couplet,
        index: 2,
        lines: ['Couplet 2'],
      );
      final song = _song(sections: [refrain, couplet1, couplet2]);

      expect(song.sectionsForDisplay, [couplet1, refrain, couplet2]);
    });

    test('regroupe refrain ET chorus après le 1er couplet', () {
      final couplet1 = const LyricSection(
        type: SectionType.couplet,
        index: 1,
        lines: ['Couplet 1'],
      );
      final couplet2 = const LyricSection(
        type: SectionType.couplet,
        index: 2,
        lines: ['Couplet 2'],
      );
      final refrain = const LyricSection(
        type: SectionType.refrain,
        lines: ['Refrain'],
      );
      final chorus = const LyricSection(
        type: SectionType.chorus,
        lines: ['Chorus'],
      );
      final song = _song(sections: [couplet1, couplet2, refrain, chorus]);

      expect(song.sectionsForDisplay, [couplet1, refrain, chorus, couplet2]);
    });
  });
}
