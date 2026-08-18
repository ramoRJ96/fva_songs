import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/domain/services/song_number_comparator.dart';

void main() {
  group('SongNumberComparator', () {
    test('trie les entiers dans l\'ordre numérique', () {
      expect(SongNumberComparator.compare('2', '10'), lessThan(0));
      expect(SongNumberComparator.compare('10', '2'), greaterThan(0));
      expect(SongNumberComparator.compare('1', '1'), 0);
    });

    test('place le numéro de base avant la variante bis', () {
      expect(SongNumberComparator.compare('28', '28 bis'), lessThan(0));
      expect(SongNumberComparator.compare('28 bis', '29'), lessThan(0));
    });

    test('retombe sur l\'ordre lexicographique pour les valeurs non numériques', () {
      expect(SongNumberComparator.compare('intro', 'outro'), lessThan(0));
    });
  });
}
