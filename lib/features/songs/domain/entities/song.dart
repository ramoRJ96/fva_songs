/// Entité Song — représente un cantique
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.number,
    required this.author,
    required this.theme,
    required this.key,
    required this.firstLine,
    required this.sections,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String number;
  final String author;
  final String theme;
  final String key;
  final String firstLine;
  final List<LyricSection> sections;
  final bool isFavorite;

  Song copyWith({bool? isFavorite}) => Song(
        id: id,
        title: title,
        number: number,
        author: author,
        theme: theme,
        key: key,
        firstLine: firstLine,
        sections: sections,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}

/// Section de paroles (Couplet ou Refrain)
class LyricSection {
  const LyricSection({
    required this.type,
    required this.lines,
    this.isBis = false,
  });

  final SectionType type;
  final List<String> lines;
  final bool isBis;
}

enum SectionType { couplet, refrain }
