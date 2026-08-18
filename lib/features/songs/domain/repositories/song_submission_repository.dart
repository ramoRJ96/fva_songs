import '../entities/song.dart';
import '../entities/song_submission.dart';

/// Contrat d'accès aux soumissions (modération).
abstract class SongSubmissionRepository {
  Stream<List<SongSubmission>> watchPending();

  Stream<List<SongSubmission>> watchMine();

  Future<SongSubmission> submitCreate(Song song);

  Future<SongSubmission> submitUpdate({
    required String targetSongId,
    required Song song,
  });

  Future<void> approve(SongSubmission submission);

  Future<void> reject(String submissionId);
}
