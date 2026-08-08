import '../entities/song.dart';

/// Contrat d'accès aux chants (indépendant de Firestore).
abstract class SongRepository {
  /// Flux temps réel du catalogue (cache offline inclus).
  Stream<List<Song>> watchSongs();

  Future<Song?> getById(String id);

  /// Crée un chant approuvé (admin) et retourne l'entité avec son id généré.
  Future<Song> addApprovedSong(Song song);

  Future<void> updateSong(Song song);

  Future<void> deleteSong(String id);
}
