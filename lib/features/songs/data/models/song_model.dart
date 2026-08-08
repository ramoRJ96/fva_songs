import '../../domain/entities/song.dart';
import '../../domain/services/text_normalizer.dart';

/// Modèle data : sérialisation Firestore <-> entité [Song].
class SongModel {
  const SongModel(this.song);

  final Song song;

  factory SongModel.fromFirestore(String id, Map<String, dynamic> data) {
    final sectionsData = (data['sections'] as List<dynamic>? ?? const []);
    final sections = sectionsData.map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      return LyricSection(
        type: _sectionTypeFromString(map['type'] as String?),
        index: map['index'] as int?,
        lines: (map['lines'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        isBis: map['isBis'] as bool? ?? false,
      );
    }).toList();

    return SongModel(
      Song(
        id: id,
        title: data['title'] as String? ?? '',
        number: data['number'] as String? ?? '',
        author: data['author'] as String? ?? '',
        theme: data['theme'] as String? ?? '',
        key: data['key'] as String? ?? '',
        language: SongLanguage.fromCode(data['language'] as String?),
        firstLine: data['firstLine'] as String? ?? '',
        sections: sections,
        searchText: data['searchText'] as String? ?? '',
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': song.title,
      'number': song.number,
      'author': song.author,
      'theme': song.theme,
      'key': song.key,
      'language': song.language.code,
      'firstLine': song.firstLine,
      'searchText': song.searchText.isNotEmpty
          ? song.searchText
          : buildSearchText(song),
      'sections': song.sections
          .map(
            (s) => {
              'type': s.type.name,
              'index': s.index,
              'lines': s.lines,
              'isBis': s.isBis,
            },
          )
          .toList(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Construit le champ dénormalisé utilisé par le filtre local.
  static String buildSearchText(Song song) {
    final parts = <String>[
      song.title,
      song.number,
      song.author,
      song.theme,
      song.key,
      song.language.code,
      song.firstLine,
      ...song.sections.expand((s) => s.lines),
    ];
    return TextNormalizer.normalize(parts.join(' '));
  }

  static SectionType _sectionTypeFromString(String? value) {
    switch (value) {
      case 'refrain':
        return SectionType.refrain;
      case 'chorus':
        return SectionType.chorus;
      case 'couplet':
      default:
        return SectionType.couplet;
    }
  }
}
