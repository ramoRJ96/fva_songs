import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/data/datasources/song_remote_datasource.dart';
import 'package:fva_songs/features/songs/data/models/song_model.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';

Song _song({
  String id = '',
  String number = '1',
  String title = 'Titre',
  SongStatus status = SongStatus.approved,
}) {
  return Song(
    id: id,
    title: title,
    number: number,
    author: '',
    theme: '',
    key: '',
    language: SongLanguage.fr,
    firstLine: '',
    sections: const [],
    status: status,
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late SongRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = SongRemoteDataSource(firestore: firestore);
  });

  group('watchSongs', () {
    test('ne renvoie que les chants approuvés, triés par numéro', () async {
      await firestore
          .collection('songs')
          .add(SongModel(_song(number: '5')).toFirestore());
      await firestore
          .collection('songs')
          .add(SongModel(_song(number: '2')).toFirestore());
      await firestore
          .collection('songs')
          .add(
            SongModel(
              _song(number: '1', status: SongStatus.pending),
            ).toFirestore(),
          );

      final songs = await dataSource.watchSongs().first;

      expect(songs, hasLength(2));
      expect(songs.map((s) => s.number), ['2', '5']);
      expect(songs.every((s) => s.status == SongStatus.approved), isTrue);
    });
  });

  group('getById', () {
    test('renvoie le chant si approuvé', () async {
      final ref = await firestore
          .collection('songs')
          .add(SongModel(_song(title: 'Approuvé')).toFirestore());

      final song = await dataSource.getById(ref.id);

      expect(song, isNotNull);
      expect(song!.title, 'Approuvé');
    });

    test('renvoie null si le chant est en attente', () async {
      final ref = await firestore
          .collection('songs')
          .add(SongModel(_song(status: SongStatus.pending)).toFirestore());

      final song = await dataSource.getById(ref.id);

      expect(song, isNull);
    });

    test('renvoie null si le document n\'existe pas', () async {
      final song = await dataSource.getById('inconnu');
      expect(song, isNull);
    });
  });

  group('addApprovedSong', () {
    test(
      'sauvegarde le chant avec statut approuvé et searchText calculé',
      () async {
        final song = _song(title: 'Nouveau', status: SongStatus.pending);

        final saved = await dataSource.addApprovedSong(song);

        expect(saved.id, isNotEmpty);
        expect(saved.status, SongStatus.approved);
        expect(saved.searchText, isNotEmpty);

        final doc = await firestore.collection('songs').doc(saved.id).get();
        expect(doc.data()!['status'], 'approved');
        expect(doc.data()!['title'], 'Nouveau');
      },
    );
  });

  group('updateSong', () {
    test(
      'met à jour le document existant et force le statut approuvé',
      () async {
        final ref = await firestore
            .collection('songs')
            .add(SongModel(_song(title: 'Ancien')).toFirestore());

        await dataSource.updateSong(
          _song(id: ref.id, title: 'Modifié', status: SongStatus.pending),
        );

        final doc = await firestore.collection('songs').doc(ref.id).get();
        expect(doc.data()!['title'], 'Modifié');
        expect(doc.data()!['status'], 'approved');
      },
    );
  });

  group('deleteSong', () {
    test('supprime le document', () async {
      final ref = await firestore
          .collection('songs')
          .add(SongModel(_song()).toFirestore());

      await dataSource.deleteSong(ref.id);

      final doc = await firestore.collection('songs').doc(ref.id).get();
      expect(doc.exists, isFalse);
    });
  });
}
