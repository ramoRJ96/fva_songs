import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/data/datasources/song_remote_datasource.dart';
import 'package:fva_songs/features/songs/data/datasources/song_submission_remote_datasource.dart';
import 'package:fva_songs/features/songs/data/models/song_model.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';
import 'package:fva_songs/features/songs/domain/entities/song_submission.dart';

Song _song({String title = 'Titre', String number = '1'}) {
  return Song(
    id: '',
    title: title,
    number: number,
    author: '',
    theme: '',
    key: '',
    language: SongLanguage.fr,
    firstLine: '',
    sections: const [],
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late SongRemoteDataSource songsDataSource;
  late SongSubmissionRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid-1', isAnonymous: false, email: 'a@b.com'),
    );
    songsDataSource = SongRemoteDataSource(firestore: firestore);
    dataSource = SongSubmissionRemoteDataSource(
      firestore: firestore,
      auth: auth,
      songs: songsDataSource,
    );
  });

  group('submitCreate', () {
    test('crée une soumission pending liée à l\'utilisateur courant', () async {
      final submission = await dataSource.submitCreate(_song(title: 'Nouveau'));

      expect(submission.id, isNotEmpty);
      expect(submission.type, SubmissionType.create);
      expect(submission.status, SubmissionStatus.pending);
      expect(submission.createdBy, 'uid-1');
      expect(submission.payload.title, 'Nouveau');
    });

    test('échoue si aucun utilisateur n\'est authentifié', () async {
      final anonAuth = MockFirebaseAuth(signedIn: false);
      final anonDataSource = SongSubmissionRemoteDataSource(
        firestore: firestore,
        auth: anonAuth,
        songs: songsDataSource,
      );

      await expectLater(anonDataSource.submitCreate(_song()), throwsStateError);
    });
  });

  group('submitUpdate', () {
    test('crée une soumission de type update avec targetSongId', () async {
      final submission = await dataSource.submitUpdate(
        targetSongId: 'song-42',
        song: _song(title: 'Modifié'),
      );

      expect(submission.type, SubmissionType.update);
      expect(submission.targetSongId, 'song-42');
      expect(submission.payload.title, 'Modifié');
    });
  });

  group('watchPending', () {
    test(
      'ne renvoie que les soumissions en attente, plus récentes en premier',
      () async {
        final older = SongSubmission(
          id: '',
          type: SubmissionType.create,
          status: SubmissionStatus.pending,
          createdBy: 'uid-1',
          payload: _song(title: 'Ancienne'),
          createdAt: DateTime.utc(2024, 1, 1),
        );
        final newer = SongSubmission(
          id: '',
          type: SubmissionType.create,
          status: SubmissionStatus.pending,
          createdBy: 'uid-1',
          payload: _song(title: 'Récente'),
          createdAt: DateTime.utc(2024, 6, 1),
        );
        final approved = SongSubmission(
          id: '',
          type: SubmissionType.create,
          status: SubmissionStatus.approved,
          createdBy: 'uid-1',
          payload: _song(title: 'Déjà traitée'),
          createdAt: DateTime.utc(2024, 3, 1),
        );

        for (final s in [older, newer, approved]) {
          await firestore.collection('song_submissions').add(_toFirestore(s));
        }

        final pending = await dataSource.watchPending().first;

        expect(pending.map((s) => s.payload.title), ['Récente', 'Ancienne']);
      },
    );
  });

  group('approve', () {
    test('publie le chant pour une soumission de création', () async {
      final submission = await dataSource.submitCreate(_song(title: 'Créé'));

      await dataSource.approve(submission);

      final songs = await songsDataSource.watchSongs().first;
      expect(songs.map((s) => s.title), contains('Créé'));

      final doc = await firestore
          .collection('song_submissions')
          .doc(submission.id)
          .get();
      expect(doc.data()!['status'], 'approved');
    });

    test(
      'met à jour le chant existant pour une soumission de modification',
      () async {
        final existing = await songsDataSource.addApprovedSong(
          _song(title: 'Avant'),
        );
        final submission = await dataSource.submitUpdate(
          targetSongId: existing.id,
          song: _song(title: 'Après'),
        );

        await dataSource.approve(submission);

        final updated = await songsDataSource.getById(existing.id);
        expect(updated!.title, 'Après');
      },
    );

    test(
      'lève une erreur si la soumission update n\'a pas de targetSongId',
      () async {
        final submission = SongSubmission(
          id: 'sub-1',
          type: SubmissionType.update,
          status: SubmissionStatus.pending,
          createdBy: 'uid-1',
          payload: _song(),
        );

        await expectLater(dataSource.approve(submission), throwsStateError);
      },
    );
  });

  group('reject', () {
    test('marque la soumission comme rejetée', () async {
      final submission = await dataSource.submitCreate(_song());

      await dataSource.reject(submission.id);

      final doc = await firestore
          .collection('song_submissions')
          .doc(submission.id)
          .get();
      expect(doc.data()!['status'], 'rejected');
    });
  });
}

Map<String, dynamic> _toFirestore(SongSubmission submission) {
  final payloadMap = SongModel(submission.payload).toFirestore();
  return {
    'type': submission.type.name,
    'status': submission.status.name,
    'createdBy': submission.createdBy,
    'targetSongId': submission.targetSongId,
    'payload': payloadMap,
    'createdAt': submission.createdAt?.toUtc().toIso8601String(),
  };
}
