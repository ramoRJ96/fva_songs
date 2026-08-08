import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../datasources/song_remote_datasource.dart';

/// Implémentation [SongRepository] via Firestore (avec cache offline).
class SongRepositoryImpl implements SongRepository {
  SongRepositoryImpl(this._remote);

  final SongRemoteDataSource _remote;

  @override
  Stream<List<Song>> watchSongs() => _remote.watchSongs();

  @override
  Future<Song?> getById(String id) => _remote.getById(id);

  @override
  Future<Song> addSong(Song song) => _remote.addSong(song);

  @override
  Future<void> updateSong(Song song) => _remote.updateSong(song);

  @override
  Future<void> deleteSong(String id) => _remote.deleteSong(id);
}
