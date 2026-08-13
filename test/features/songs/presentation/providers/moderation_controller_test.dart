import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/entities/song_submission.dart';
import 'package:fva_songs/features/songs/domain/repositories/song_submission_repository.dart';
import 'package:fva_songs/features/songs/presentation/providers/songs_providers.dart';

class MockSongSubmissionRepository extends Mock
    implements SongSubmissionRepository {}

void main() {
  late MockSongSubmissionRepository repository;
  late ModerationController controller;

  setUpAll(() {
    registerFallbackValue(
      SongSubmission(
        id: '',
        type: SubmissionType.create,
        status: SubmissionStatus.pending,
        createdBy: '',
        payload: const Song(
          id: '',
          title: '',
          number: '',
          author: '',
          theme: '',
          key: '',
          language: SongLanguage.fr,
          firstLine: '',
          sections: [],
        ),
      ),
    );
  });

  setUp(() {
    repository = MockSongSubmissionRepository();
    controller = ModerationController(repository);
  });

  test('approve délègue au repository', () async {
    final submission = SongSubmission(
      id: 'sub-1',
      type: SubmissionType.create,
      status: SubmissionStatus.pending,
      createdBy: 'uid',
      payload: const Song(
        id: '',
        title: 'T',
        number: '1',
        author: '',
        theme: '',
        key: '',
        language: SongLanguage.fr,
        firstLine: '',
        sections: [],
      ),
    );
    when(() => repository.approve(submission)).thenAnswer((_) async {});

    await controller.approve(submission);

    verify(() => repository.approve(submission)).called(1);
  });

  test('reject délègue au repository', () async {
    when(() => repository.reject('sub-1')).thenAnswer((_) async {});

    await controller.reject('sub-1');

    verify(() => repository.reject('sub-1')).called(1);
  });
}
