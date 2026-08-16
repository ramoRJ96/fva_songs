import '../entities/song.dart';
import 'text_normalizer.dart';

/// Portée du filtre de recherche (chip sélectionnée).
enum SearchScope {
  all,
  title,
  number,
  author,
  theme,
  key,
  language,
  favorites,
}

/// Service pur de filtrage / ranking des chants.
///
/// Responsabilité unique (SOLID-S) : transformer une liste + critères
/// en liste triée par pertinence. Aucune dépendance Firebase/UI.
class SongFilterService {
  const SongFilterService();

  /// Filtre et classe les chants pour une recherche ultra-rapide en mémoire.
  List<Song> filter({
    required List<Song> songs,
    required String query,
    required SearchScope scope,
    required Set<String> favoriteIds,
  }) {
    final normalizedQuery = TextNormalizer.normalize(query);

    // Filtre "Favoris" sans texte : uniquement les favoris.
    if (scope == SearchScope.favorites && normalizedQuery.isEmpty) {
      return songs.where((s) => favoriteIds.contains(s.id)).toList();
    }

    Iterable<Song> candidates = songs;

    if (scope == SearchScope.favorites) {
      candidates = candidates.where((s) => favoriteIds.contains(s.id));
    }

    if (normalizedQuery.isEmpty) {
      // Même instance → Riverpod ne notifie pas la liste sans besoin.
      return songs;
    }

    final scored = <_ScoredSong>[];

    for (final song in candidates) {
      final score = _score(song, normalizedQuery, scope);
      if (score > 0) {
        scored.add(_ScoredSong(song, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.song).toList();
  }

  /// Score de pertinence (> 0 = match).
  ///
  /// Ordre voulu :
  /// 1. Numéro exact
  /// 2. Titre commence par la query
  /// 3. Contains sur le champ ciblé / searchText
  int _score(Song song, String query, SearchScope scope) {
    final title = TextNormalizer.normalize(song.title);
    final number = TextNormalizer.normalize(song.number);
    final author = TextNormalizer.normalize(song.author);
    final theme = TextNormalizer.normalize(song.theme);
    final key = TextNormalizer.normalize(song.key);
    final language = song.language.code;
    final searchText = song.searchText.isNotEmpty
        ? song.searchText
        : TextNormalizer.normalize(
            [
              song.title,
              song.number,
              song.author,
              song.theme,
              song.key,
              song.firstLine,
              ...song.sections.expand((s) => s.lines),
            ].join(' '),
          );

    // Match exact numéro → priorité max.
    if (number == query) return 1000;

    switch (scope) {
      case SearchScope.title:
        return _fieldScore(title, query, startsBoost: 800);
      case SearchScope.number:
        return number.contains(query) ? 700 : 0;
      case SearchScope.author:
        return _fieldScore(author, query, startsBoost: 600);
      case SearchScope.theme:
        return _fieldScore(theme, query, startsBoost: 500);
      case SearchScope.key:
        return _fieldScore(key, query, startsBoost: 500);
      case SearchScope.language:
        return language.contains(query) ||
                (query == 'francais' && language == 'fr') ||
                (query == 'malagasy' && language == 'mg')
            ? 400
            : 0;
      case SearchScope.favorites:
      case SearchScope.all:
        if (title.startsWith(query)) return 800;
        if (number.contains(query)) return 700;
        if (title.contains(query)) return 600;
        if (author.contains(query)) return 500;
        if (theme.contains(query) || key.contains(query)) return 400;
        if (searchText.contains(query)) return 300;
        return 0;
    }
  }

  int _fieldScore(String field, String query, {required int startsBoost}) {
    if (field.startsWith(query)) return startsBoost;
    if (field.contains(query)) return startsBoost ~/ 2;
    return 0;
  }
}

class _ScoredSong {
  const _ScoredSong(this.song, this.score);
  final Song song;
  final int score;
}
