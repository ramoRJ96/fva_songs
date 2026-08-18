import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fva_songs/features/songs/data/datasources/song_submission_remote_datasource.dart';
import 'package:fva_songs/features/songs/data/repositories/song_submission_repository_impl.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/entities/song_submission.dart';

class MockSongSubmissionRemoteDataSource extends Mock
    implements SongSubmissionRemoteDataSource {}

Song _song() {
  return const Song(
    id: '',
    title: 'Titre',
    number: '1',
    author: '',
    theme: '',
    key: '',
    language: SongLanguage.fr,
    firstLine: '',
    sections: [],
  );
}

SongSubmission _submission() {
  return SongSubmission(
    id: 'sub-1',
    type: SubmissionType.create,
    status: SubmissionStatus.pending,
    createdBy: 'uid',
    payload: _song(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_song());
    registerFallbackValue(_submission());
  });

  late MockSongSubmissionRemoteDataSource remote;
  late SongSubmissionRepositoryImpl repository;

  setUp(() {
    remote = MockSongSubmissionRemoteDataSource();
    repository = SongSubmissionRepositoryImpl(remote);
  });

  test('watchPending délègue à la datasource', () {
    final stream = Stream<List<SongSubmission>>.value([_submission()]);
    when(() => remote.watchPending()).thenAnswer((_) => stream);

    expect(repository.watchPending(), stream);
  });

  test('watchMine délègue à la datasource', () {
    final stream = Stream<List<SongSubmission>>.value([_submission()]);
    when(() => remote.watchMine()).thenAnswer((_) => stream);

    expect(repository.watchMine(), stream);
  });

  test('submitCreate délègue à la datasource', () async {
    final song = _song();
    final submission = _submission();
    when(() => remote.submitCreate(song)).thenAnswer((_) async => submission);

    final result = await repository.submitCreate(song);

    expect(result, submission);
    verify(() => remote.submitCreate(song)).called(1);
  });

  test('submitUpdate délègue à la datasource avec targetSongId', () async {
    final song = _song();
    final submission = _submission();
    when(
      () => remote.submitUpdate(targetSongId: 'target-1', song: song),
    ).thenAnswer((_) async => submission);

    final result = await repository.submitUpdate(
      targetSongId: 'target-1',
      song: song,
    );

    expect(result, submission);
    verify(
      () => remote.submitUpdate(targetSongId: 'target-1', song: song),
    ).called(1);
  });

  test('approve délègue à la datasource', () async {
    final submission = _submission();
    when(() => remote.approve(submission)).thenAnswer((_) async {});

    await repository.approve(submission);

    verify(() => remote.approve(submission)).called(1);
  });

  test('reject délègue à la datasource', () async {
    when(() => remote.reject('sub-1')).thenAnswer((_) async {});

    await repository.reject('sub-1');

    verify(() => remote.reject('sub-1')).called(1);
  });
}
