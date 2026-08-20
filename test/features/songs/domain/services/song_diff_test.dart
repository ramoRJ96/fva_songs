import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/services/song_diff.dart';

Song _song({
  String title = 'Titre',
  String number = '1',
  String author = 'Auteur',
  String theme = 'Louange',
  String key = 'G',
  SongLanguage language = SongLanguage.fr,
  List<LyricSection> sections = const [
    LyricSection(type: SectionType.couplet, index: 1, lines: ['Ligne']),
  ],
}) {
  return Song(
    id: 'id',
    title: title,
    number: number,
    author: author,
    theme: theme,
    key: key,
    language: language,
    firstLine: '',
    sections: sections,
  );
}

void main() {
  group('SongDiff.compare', () {
    test('aucun changement si identique', () {
      final song = _song();
      final diff = SongDiff.compare(current: song, proposed: song);

      expect(diff.hasChanges, isFalse);
      expect(diff.lyricsChanged, isFalse);
      expect(diff.fields.every((field) => !field.changed), isTrue);
    });

    test('détecte un champ métadonnée modifié', () {
      final diff = SongDiff.compare(
        current: _song(title: 'Ancien'),
        proposed: _song(title: 'Nouveau'),
      );

      expect(diff.hasMetadataChanges, isTrue);
      expect(diff.lyricsChanged, isFalse);
      expect(
        diff.fields.singleWhere((field) => field.key == 'title').changed,
        isTrue,
      );
    });

    test('détecte un changement de paroles', () {
      final diff = SongDiff.compare(
        current: _song(),
        proposed: _song(
          sections: const [
            LyricSection(
              type: SectionType.couplet,
              index: 1,
              lines: ['Autre ligne'],
            ),
          ],
        ),
      );

      expect(diff.lyricsChanged, isTrue);
      expect(diff.hasMetadataChanges, isFalse);
    });

    test('sans chant actuel, les paroles proposées comptent comme un écart', () {
      final diff = SongDiff.compare(current: null, proposed: _song());

      expect(diff.hasChanges, isTrue);
      expect(diff.lyricsChanged, isTrue);
      expect(
        diff.fields.singleWhere((field) => field.key == 'title').current,
        '',
      );
    });
  });
}
