import '../../domain/entities/song.dart';
import '../../domain/entities/song_submission.dart';
import '../../domain/repositories/song_submission_repository.dart';
import '../datasources/song_submission_remote_datasource.dart';

class SongSubmissionRepositoryImpl implements SongSubmissionRepository {
  SongSubmissionRepositoryImpl(this._remote);

  final SongSubmissionRemoteDataSource _remote;

  @override
  Stream<List<SongSubmission>> watchPending() => _remote.watchPending();

  @override
  Stream<List<SongSubmission>> watchMine() => _remote.watchMine();

  @override
  Future<SongSubmission> submitCreate(Song song) => _remote.submitCreate(song);

  @override
  Future<SongSubmission> submitUpdate({
    required String targetSongId,
    required Song song,
  }) {
    return _remote.submitUpdate(targetSongId: targetSongId, song: song);
  }

  @override
  Future<void> approve(SongSubmission submission) => _remote.approve(submission);

  @override
  Future<void> reject(String submissionId) => _remote.reject(submissionId);
}
