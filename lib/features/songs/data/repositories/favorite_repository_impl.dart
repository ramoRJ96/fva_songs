import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_remote_datasource.dart';

/// Implémentation [FavoriteRepository] scoped à l'utilisateur anonyme.
class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl(this._remote);

  final FavoriteRemoteDataSource _remote;

  @override
  Stream<Set<String>> watchFavoriteIds() => _remote.watchFavoriteIds();

  @override
  Future<void> addFavorite(String songId) => _remote.addFavorite(songId);

  @override
  Future<void> removeFavorite(String songId) => _remote.removeFavorite(songId);

  @override
  Future<void> toggleFavorite(
    String songId, {
    required bool currentlyFavorite,
  }) {
    if (currentlyFavorite) {
      return removeFavorite(songId);
    }
    return addFavorite(songId);
  }
}
