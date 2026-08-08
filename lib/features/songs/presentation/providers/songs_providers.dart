import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/favorite_remote_datasource.dart';
import '../../data/datasources/song_remote_datasource.dart';
import '../../data/datasources/song_submission_remote_datasource.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../data/repositories/song_repository_impl.dart';
import '../../data/repositories/song_submission_repository_impl.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/song_submission.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/repositories/song_repository.dart';
import '../../domain/repositories/song_submission_repository.dart';
import '../../domain/services/song_filter_service.dart';

// ---------------------------------------------------------------------------
// Injection des dépendances (DIP)
// ---------------------------------------------------------------------------

final songRemoteDataSourceProvider = Provider<SongRemoteDataSource>((ref) {
  return SongRemoteDataSource();
});

final songSubmissionRemoteDataSourceProvider =
    Provider<SongSubmissionRemoteDataSource>((ref) {
  return SongSubmissionRemoteDataSource(
    songs: ref.watch(songRemoteDataSourceProvider),
  );
});

final favoriteRemoteDataSourceProvider =
    Provider<FavoriteRemoteDataSource>((ref) {
  return FavoriteRemoteDataSource();
});

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepositoryImpl(ref.watch(songRemoteDataSourceProvider));
});

final songSubmissionRepositoryProvider =
    Provider<SongSubmissionRepository>((ref) {
  return SongSubmissionRepositoryImpl(
    ref.watch(songSubmissionRemoteDataSourceProvider),
  );
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(ref.watch(favoriteRemoteDataSourceProvider));
});

final songFilterServiceProvider = Provider<SongFilterService>((ref) {
  return const SongFilterService();
});

// ---------------------------------------------------------------------------
// Catalogue Firestore (offline cache inclus)
// ---------------------------------------------------------------------------

/// Stream du catalogue complet — source de vérité pour la liste.
final songsCatalogProvider = StreamProvider<List<Song>>((ref) {
  return ref.watch(songRepositoryProvider).watchSongs();
});

/// Lookup d'un chant par id dans le catalogue déjà chargé.
final songByIdProvider = Provider.family<Song?, String>((ref, id) {
  final catalog = ref.watch(songsCatalogProvider).valueOrNull;
  if (catalog == null) return null;
  for (final song in catalog) {
    if (song.id == id) return song;
  }
  return null;
});

// ---------------------------------------------------------------------------
// Favoris
// ---------------------------------------------------------------------------

final favoriteIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(favoriteRepositoryProvider).watchFavoriteIds();
});

final isFavoriteProvider = Provider.family<bool, String>((ref, songId) {
  final ids = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
  return ids.contains(songId);
});

/// Chants favoris = intersection catalogue ∩ ids favoris.
final favoriteSongsProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(songsCatalogProvider).valueOrNull ?? const [];
  final ids = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
  return songs.where((s) => ids.contains(s.id)).toList();
});

final favoritesControllerProvider = Provider<FavoritesController>((ref) {
  return FavoritesController(ref.watch(favoriteRepositoryProvider));
});

class FavoritesController {
  FavoritesController(this._repository);

  final FavoriteRepository _repository;

  Future<void> toggle(String songId, {required bool currentlyFavorite}) {
    return _repository.toggleFavorite(
      songId,
      currentlyFavorite: currentlyFavorite,
    );
  }
}

// ---------------------------------------------------------------------------
// Recherche / filtre (priorité produit)
// ---------------------------------------------------------------------------

/// Texte saisi (mis à jour avec debounce côté UI).
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Portée active du filtre (chip).
final searchScopeProvider =
    StateProvider<SearchScope>((ref) => SearchScope.all);

/// Résultat filtré + classé pour affichage immédiat.
final filteredSongsProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(songsCatalogProvider).valueOrNull ?? const [];
  final query = ref.watch(searchQueryProvider);
  final scope = ref.watch(searchScopeProvider);
  final favoriteIds = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
  final filter = ref.watch(songFilterServiceProvider);

  return filter.filter(
    songs: songs,
    query: query,
    scope: scope,
    favoriteIds: favoriteIds,
  );
});

// ---------------------------------------------------------------------------
// Ajout / modification de chant (soumission ou publish admin)
// ---------------------------------------------------------------------------

/// Résultat d'un enregistrement : publié tout de suite ou en attente.
enum SongSaveOutcome { published, pendingReview }

final addSongControllerProvider = Provider<AddSongController>((ref) {
  return AddSongController(
    songs: ref.watch(songRepositoryProvider),
    submissions: ref.watch(songSubmissionRepositoryProvider),
    isAdmin: () => ref.read(isAdminProvider).valueOrNull ?? false,
  );
});

class AddSongController {
  AddSongController({
    required SongRepository songs,
    required SongSubmissionRepository submissions,
    required bool Function() isAdmin,
  })  : _songs = songs,
        _submissions = submissions,
        _isAdmin = isAdmin;

  final SongRepository _songs;
  final SongSubmissionRepository _submissions;
  final bool Function() _isAdmin;

  Future<SongSaveOutcome> save({
    required String title,
    required String number,
    required String author,
    required String theme,
    required String key,
    required SongLanguage language,
    required List<LyricSection> sections,
    String? editingSongId,
  }) async {
    final firstLine = _computeFirstLine(sections);
    final song = Song(
      id: editingSongId ?? '',
      title: title.trim(),
      number: number.trim(),
      author: author.trim(),
      theme: theme.trim(),
      key: key.trim(),
      language: language,
      firstLine: firstLine,
      sections: sections,
      status: SongStatus.approved,
    );

    final admin = _isAdmin();
    final isEdit = editingSongId != null && editingSongId.isNotEmpty;

    if (admin) {
      if (isEdit) {
        await _songs.updateSong(song);
      } else {
        await _songs.addApprovedSong(song);
      }
      return SongSaveOutcome.published;
    }

    if (isEdit) {
      await _submissions.submitUpdate(
        targetSongId: editingSongId,
        song: song,
      );
    } else {
      await _submissions.submitCreate(song);
    }
    return SongSaveOutcome.pendingReview;
  }

  String _computeFirstLine(List<LyricSection> sections) {
    for (final section in sections) {
      for (final line in section.lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          return '«\u00a0$trimmed\u00a0»';
        }
      }
    }
    return '';
  }
}

// ---------------------------------------------------------------------------
// Modération admin
// ---------------------------------------------------------------------------

final pendingSubmissionsProvider =
    StreamProvider<List<SongSubmission>>((ref) {
  return ref.watch(songSubmissionRepositoryProvider).watchPending();
});

final moderationControllerProvider = Provider<ModerationController>((ref) {
  return ModerationController(ref.watch(songSubmissionRepositoryProvider));
});

class ModerationController {
  ModerationController(this._repository);

  final SongSubmissionRepository _repository;

  Future<void> approve(SongSubmission submission) =>
      _repository.approve(submission);

  Future<void> reject(String submissionId) => _repository.reject(submissionId);
}

/// Helper debounce pour la barre de recherche.
class SearchDebouncer {
  SearchDebouncer({this.delay = const Duration(milliseconds: 200)});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
