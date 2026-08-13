import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/data/models/song_model.dart';
import 'package:fva_songs/features/songs/data/models/song_submission_model.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/entities/song_submission.dart';

void main() {
  group('SongSubmissionModel.fromFirestore', () {
    test('parse une soumission de création', () {
      final model = SongSubmissionModel.fromFirestore('sub-1', {
        'type': 'create',
        'status': 'pending',
        'createdBy': 'uid-123',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'payload': {'title': 'Nouveau chant', 'number': '99', 'language': 'mg'},
      });

      final submission = model.submission;
      expect(submission.id, 'sub-1');
      expect(submission.type, SubmissionType.create);
      expect(submission.status, SubmissionStatus.pending);
      expect(submission.createdBy, 'uid-123');
      expect(submission.targetSongId, isNull);
      expect(submission.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(submission.payload.title, 'Nouveau chant');
      expect(submission.payload.number, '99');
      expect(submission.payload.language, SongLanguage.mg);
      expect(submission.isPending, isTrue);
    });

    test('parse une soumission de mise à jour avec targetSongId', () {
      final model = SongSubmissionModel.fromFirestore('sub-2', {
        'type': 'update',
        'status': 'approved',
        'createdBy': 'uid-456',
        'targetSongId': 'song-42',
        'payload': {'title': 'Titre modifié'},
      });

      final submission = model.submission;
      expect(submission.type, SubmissionType.update);
      expect(submission.status, SubmissionStatus.approved);
      expect(submission.targetSongId, 'song-42');
      expect(submission.isPending, isFalse);
    });

    test('valeurs par défaut si champs absents', () {
      final model = SongSubmissionModel.fromFirestore('sub-3', const {});
      final submission = model.submission;

      expect(submission.type, SubmissionType.create);
      expect(submission.status, SubmissionStatus.pending);
      expect(submission.createdBy, '');
      expect(submission.createdAt, isNull);
      expect(submission.payload.title, '');
    });

    test('createdAt invalide devient null', () {
      final model = SongSubmissionModel.fromFirestore('sub-4', {
        'createdAt': 'pas-une-date',
      });
      expect(model.submission.createdAt, isNull);
    });
  });

  group('SongSubmissionModel.toFirestore', () {
    test('sérialise les champs et le payload imbriqué', () {
      final createdAt = DateTime.utc(2024, 3, 1, 8, 0, 0);
      const payload = Song(
        id: 'target-id',
        title: 'Titre',
        number: '10',
        author: '',
        theme: '',
        key: '',
        language: SongLanguage.fr,
        firstLine: '',
        sections: [],
      );
      final submission = SongSubmission(
        id: 'ignored',
        type: SubmissionType.update,
        status: SubmissionStatus.pending,
        createdBy: 'uid-789',
        targetSongId: 'song-10',
        payload: payload,
        createdAt: createdAt,
      );

      final map = SongSubmissionModel(submission).toFirestore();

      expect(map['type'], 'update');
      expect(map['status'], 'pending');
      expect(map['createdBy'], 'uid-789');
      expect(map['targetSongId'], 'song-10');
      expect(map['createdAt'], createdAt.toIso8601String());

      final actualPayload = Map<String, dynamic>.from(map['payload'] as Map)
        ..remove('updatedAt');
      final expectedPayload = SongModel(payload).toFirestore()
        ..remove('updatedAt');
      expect(actualPayload, expectedPayload);
    });

    test('utilise l\'heure actuelle si createdAt est null', () {
      const payload = Song(
        id: '',
        title: 'T',
        number: '1',
        author: '',
        theme: '',
        key: '',
        language: SongLanguage.fr,
        firstLine: '',
        sections: [],
      );
      final submission = SongSubmission(
        id: '',
        type: SubmissionType.create,
        status: SubmissionStatus.pending,
        createdBy: 'uid',
        payload: payload,
      );

      final before = DateTime.now().toUtc();
      final map = SongSubmissionModel(submission).toFirestore();
      final after = DateTime.now().toUtc();

      final parsed = DateTime.parse(map['createdAt'] as String);
      expect(
        parsed.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(parsed.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });
}
