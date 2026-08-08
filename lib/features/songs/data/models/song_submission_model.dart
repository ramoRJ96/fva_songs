import '../../domain/entities/song_submission.dart';
import 'song_model.dart';

/// Sérialisation Firestore <-> [SongSubmission].
class SongSubmissionModel {
  const SongSubmissionModel(this.submission);

  final SongSubmission submission;

  factory SongSubmissionModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final payloadData = Map<String, dynamic>.from(
      data['payload'] as Map? ?? const {},
    );
    final payloadId = data['targetSongId'] as String? ?? '';
    final payload = SongModel.fromFirestore(payloadId, payloadData).song;

    DateTime? createdAt;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    }

    return SongSubmissionModel(
      SongSubmission(
        id: id,
        type: SubmissionType.fromString(data['type'] as String?),
        status: SubmissionStatus.fromString(data['status'] as String?),
        createdBy: data['createdBy'] as String? ?? '',
        targetSongId: data['targetSongId'] as String?,
        payload: payload,
        createdAt: createdAt,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    final payloadMap = SongModel(submission.payload).toFirestore();
    return {
      'type': submission.type.name,
      'status': submission.status.name,
      'createdBy': submission.createdBy,
      'targetSongId': submission.targetSongId,
      'payload': payloadMap,
      'createdAt':
          submission.createdAt?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String(),
    };
  }
}
