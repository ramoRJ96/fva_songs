import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/domain/services/text_normalizer.dart';

void main() {
  group('TextNormalizer.normalize', () {
    test('met en minuscule', () {
      expect(TextNormalizer.normalize('AFAKA'), 'afaka');
    });

    test('retire les accents connus', () {
      expect(TextNormalizer.normalize('Déraiko Tompo ô!'), 'deraiko tompo o!');

      const accented = 'àâäáãåèêëéìîïíòôöóõùûüúçñÿ';
      const expected = 'aaaaaaeeeeiiiiooooouuuucny';
      final result = TextNormalizer.normalize(accented);
      expect(result.length, accented.length);
      expect(result, expected);
    });

    test('retire les espaces en début/fin', () {
      expect(TextNormalizer.normalize('  bonjour  '), 'bonjour');
    });

    test('laisse les caractères non accentués inchangés', () {
      expect(TextNormalizer.normalize('123 abc!'), '123 abc!');
    });

    test('gère la chaîne vide', () {
      expect(TextNormalizer.normalize(''), '');
    });
  });
}
