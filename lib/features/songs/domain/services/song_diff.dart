import '../entities/song.dart';

/// Écart d'un champ métadonnée entre le chant publié et une proposition.
class SongFieldDiff {
  const SongFieldDiff({
    required this.key,
    required this.current,
    required this.proposed,
  });

  /// Identifiant stable (`title`, `number`, `author`, `theme`, `key`, `language`).
  final String key;
  final String current;
  final String proposed;

  bool get changed => current != proposed;
}

/// Comparaison pur domaine d'une soumission `update` avec le chant actuel.
class SongDiff {
  const SongDiff({
    required this.fields,
    required this.lyricsChanged,
  });

  final List<SongFieldDiff> fields;
  final bool lyricsChanged;

  bool get hasMetadataChanges => fields.any((field) => field.changed);

  bool get hasChanges => hasMetadataChanges || lyricsChanged;

  factory SongDiff.compare({
    Song? current,
    required Song proposed,
  }) {
    String value(String? raw) => raw ?? '';

    return SongDiff(
      fields: [
        SongFieldDiff(
          key: 'title',
          current: value(current?.title),
          proposed: proposed.title,
        ),
        SongFieldDiff(
          key: 'number',
          current: value(current?.number),
          proposed: proposed.number,
        ),
        SongFieldDiff(
          key: 'author',
          current: value(current?.author),
          proposed: proposed.author,
        ),
        SongFieldDiff(
          key: 'theme',
          current: value(current?.theme),
          proposed: proposed.theme,
        ),
        SongFieldDiff(
          key: 'key',
          current: value(current?.key),
          proposed: proposed.key,
        ),
        SongFieldDiff(
          key: 'language',
          current: value(current?.language.code),
          proposed: proposed.language.code,
        ),
      ],
      lyricsChanged: current == null
          ? proposed.sections.isNotEmpty
          : _lyricsDump(current) != _lyricsDump(proposed),
    );
  }

  static String _lyricsDump(Song song) {
    return song.sections
        .map(
          (section) => [
            section.type.name,
            '${section.index ?? ''}',
            '${section.isBis}',
            section.lines.join('\n'),
          ].join('|'),
        )
        .join('\n---\n');
  }
}
