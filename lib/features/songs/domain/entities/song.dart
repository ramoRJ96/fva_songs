/// Langue du contenu d'un chant (indépendante de la langue de l'UI).
enum SongLanguage {
  fr('fr'),
  mg('mg');

  const SongLanguage(this.code);
  final String code;

  static SongLanguage fromCode(String? code) {
    if (code == 'mg') return SongLanguage.mg;
    return SongLanguage.fr;
  }
}

/// Type de section de paroles.
enum SectionType {
  /// Couplet numéroté (1, 2, 3...).
  couplet,

  /// Refrain classique.
  refrain,

  /// Chorus optionnel (souvent distinct du refrain).
  chorus,
}

/// Section de paroles (couplet, refrain ou chorus).
class LyricSection {
  const LyricSection({
    required this.type,
    required this.lines,
    this.index,
    this.isBis = false,
  });

  final SectionType type;

  /// Numéro du couplet (1, 2, 3...). Null pour refrain/chorus.
  final int? index;

  final List<String> lines;
  final bool isBis;
}

/// Statut de publication d'un chant dans le catalogue.
enum SongStatus {
  /// Visible par tous les utilisateurs.
  approved,

  /// Non visible (legacy / brouillon éventuel).
  pending;

  static SongStatus fromString(String? value) {
    if (value == 'pending') return SongStatus.pending;
    // Absent ou inconnu → traité comme approuvé (migration douce).
    return SongStatus.approved;
  }
}

/// Entité domaine : un cantique / chant d'église.
///
/// Indépendante de Firestore (Clean Architecture — couche Domain).
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.number,
    required this.author,
    required this.theme,
    required this.key,
    required this.language,
    required this.firstLine,
    required this.sections,
    this.searchText = '',
    this.status = SongStatus.approved,
  });

  final String id;
  final String title;

  /// Numéro du cantique (ex. "84").
  final String number;
  final String author;
  final String theme;

  /// Tonalité pour les musiciens (ex. "G maj").
  final String key;
  final SongLanguage language;
  final String firstLine;
  final List<LyricSection> sections;

  /// Texte normalisé pour la recherche rapide (dénormalisé à l'écriture).
  final String searchText;

  final SongStatus status;

  Song copyWith({
    String? id,
    String? title,
    String? number,
    String? author,
    String? theme,
    String? key,
    SongLanguage? language,
    String? firstLine,
    List<LyricSection>? sections,
    String? searchText,
    SongStatus? status,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      number: number ?? this.number,
      author: author ?? this.author,
      theme: theme ?? this.theme,
      key: key ?? this.key,
      language: language ?? this.language,
      firstLine: firstLine ?? this.firstLine,
      sections: sections ?? this.sections,
      searchText: searchText ?? this.searchText,
      status: status ?? this.status,
    );
  }
}
