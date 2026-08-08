/// Contrat des favoris utilisateur (par uid anonyme).
abstract class FavoriteRepository {
  /// Flux des ids de chants favoris.
  Stream<Set<String>> watchFavoriteIds();

  Future<void> addFavorite(String songId);

  Future<void> removeFavorite(String songId);

  Future<void> toggleFavorite(String songId, {required bool currentlyFavorite});
}
