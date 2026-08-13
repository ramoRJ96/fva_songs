import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/entities/song_submission.dart';

Song _payload() {
  return const Song(
    id: '',
    title: 'Titre',
    number: '1',
    author: '',
    theme: '',
    key: '',
    language: SongLanguage.mg,
    firstLine: '',
    sections: [],
  );
}

void main() {
  group('SubmissionType.fromString', () {
    test('reconnaît "update"', () {
      expect(SubmissionType.fromString('update'), SubmissionType.update);
    });

    test('retombe sur create par défaut', () {
      expect(SubmissionType.fromString('create'), SubmissionType.create);
      expect(SubmissionType.fromString(null), SubmissionType.create);
      expect(SubmissionType.fromString('other'), SubmissionType.create);
    });
  });

  group('SubmissionStatus.fromString', () {
    test('reconnaît approved et rejected', () {
      expect(
        SubmissionStatus.fromString('approved'),
        SubmissionStatus.approved,
      );
      expect(
        SubmissionStatus.fromString('rejected'),
        SubmissionStatus.rejected,
      );
    });

    test('retombe sur pending par défaut', () {
      expect(SubmissionStatus.fromString('pending'), SubmissionStatus.pending);
      expect(SubmissionStatus.fromString(null), SubmissionStatus.pending);
      expect(SubmissionStatus.fromString('other'), SubmissionStatus.pending);
    });
  });

  group('SongSubmission.isPending', () {
    test('true uniquement quand status == pending', () {
      final pending = SongSubmission(
        id: '1',
        type: SubmissionType.create,
        status: SubmissionStatus.pending,
        createdBy: 'uid',
        payload: _payload(),
      );
      final approved = SongSubmission(
        id: '2',
        type: SubmissionType.create,
        status: SubmissionStatus.approved,
        createdBy: 'uid',
        payload: _payload(),
      );
      final rejected = SongSubmission(
        id: '3',
        type: SubmissionType.create,
        status: SubmissionStatus.rejected,
        createdBy: 'uid',
        payload: _payload(),
      );

      expect(pending.isPending, isTrue);
      expect(approved.isPending, isFalse);
      expect(rejected.isPending, isFalse);
    });
  });
}
