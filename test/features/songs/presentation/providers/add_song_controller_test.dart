import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/entities/song_submission.dart';
import 'package:fva_songs/features/songs/domain/repositories/song_repository.dart';
import 'package:fva_songs/features/songs/domain/repositories/song_submission_repository.dart';
import 'package:fva_songs/features/songs/presentation/providers/songs_providers.dart';

class MockSongRepository extends Mock implements SongRepository {}

class MockSongSubmissionRepository extends Mock
    implements SongSubmissionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Song(
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
    );
  });

  late MockSongRepository songs;
  late MockSongSubmissionRepository submissions;

  AddSongController buildController({required bool isAdmin}) {
    return AddSongController(
      songs: songs,
      submissions: submissions,
      isAdmin: () => isAdmin,
    );
  }

  setUp(() {
    songs = MockSongRepository();
    submissions = MockSongSubmissionRepository();
  });

  group('admin', () {
    test('publie directement un nouveau chant', () async {
      when(() => songs.addApprovedSong(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Song,
      );

      final controller = buildController(isAdmin: true);
      final outcome = await controller.save(
        title: '  Mon titre  ',
        number: ' 12 ',
        author: ' Auteur ',
        theme: ' Thème ',
        key: ' C ',
        language: SongLanguage.fr,
        sections: const [
          LyricSection(
            type: SectionType.couplet,
            index: 1,
            lines: ['  Première ligne  '],
          ),
        ],
      );

      expect(outcome, SongSaveOutcome.published);
      final captured =
          verify(() => songs.addApprovedSong(captureAny())).captured.single
              as Song;
      expect(captured.title, 'Mon titre');
      expect(captured.number, '12');
      expect(captured.author, 'Auteur');
      expect(captured.theme, 'Thème');
      expect(captured.key, 'C');
      expect(captured.firstLine, '«\u{00a0}Première ligne\u{00a0}»');
      expect(captured.status, SongStatus.approved);
      verifyNever(() => submissions.submitCreate(any()));
    });

    test('publie une modification directement (updateSong)', () async {
      when(() => songs.updateSong(any())).thenAnswer((_) async {});

      final controller = buildController(isAdmin: true);
      final outcome = await controller.save(
        title: 'Titre modifié',
        number: '5',
        author: '',
        theme: '',
        key: '',
        language: SongLanguage.mg,
        sections: const [],
        editingSongId: 'song-5',
      );

      expect(outcome, SongSaveOutcome.published);
      final captured =
          verify(() => songs.updateSong(captureAny())).captured.single as Song;
      expect(captured.id, 'song-5');
      expect(captured.title, 'Titre modifié');
      verifyNever(() => songs.addApprovedSong(any()));
    });
  });

  group('utilisateur non admin', () {
    test('soumet une création à la modération', () async {
      when(() => submissions.submitCreate(any())).thenAnswer(
        (invocation) async => SongSubmission(
          id: 'sub-1',
          type: SubmissionType.create,
          status: SubmissionStatus.pending,
          createdBy: 'uid',
          payload: invocation.positionalArguments[0] as Song,
        ),
      );

      final controller = buildController(isAdmin: false);
      final outcome = await controller.save(
        title: 'Nouveau chant',
        number: '99',
        author: '',
        theme: '',
        key: '',
        language: SongLanguage.fr,
        sections: const [],
      );

      expect(outcome, SongSaveOutcome.pendingReview);
      verify(() => submissions.submitCreate(any())).called(1);
      verifyNever(() => songs.addApprovedSong(any()));
    });

    test('soumet une modification à la modération avec targetSongId', () async {
      when(
        () => submissions.submitUpdate(
          targetSongId: any(named: 'targetSongId'),
          song: any(named: 'song'),
        ),
      ).thenAnswer(
        (invocation) async => SongSubmission(
          id: 'sub-2',
          type: SubmissionType.update,
          status: SubmissionStatus.pending,
          createdBy: 'uid',
          targetSongId: invocation.namedArguments[#targetSongId] as String,
          payload: invocation.namedArguments[#song] as Song,
        ),
      );

      final controller = buildController(isAdmin: false);
      final outcome = await controller.save(
        title: 'Chant modifié',
        number: '10',
        author: '',
        theme: '',
        key: '',
        language: SongLanguage.fr,
        sections: const [],
        editingSongId: 'song-10',
      );

      expect(outcome, SongSaveOutcome.pendingReview);
      verify(
        () => submissions.submitUpdate(
          targetSongId: 'song-10',
          song: any(named: 'song'),
        ),
      ).called(1);
      verifyNever(() => songs.updateSong(any()));
    });
  });

  group('computeFirstLine', () {
    test('vide si toutes les lignes sont vides', () async {
      when(() => songs.addApprovedSong(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Song,
      );

      final controller = buildController(isAdmin: true);
      await controller.save(
        title: 'T',
        number: '1',
        author: '',
        theme: '',
        key: '',
        language: SongLanguage.fr,
        sections: const [
          LyricSection(type: SectionType.couplet, lines: ['   ', '']),
        ],
      );

      final captured =
          verify(() => songs.addApprovedSong(captureAny())).captured.single
              as Song;
      expect(captured.firstLine, '');
    });
  });
}
