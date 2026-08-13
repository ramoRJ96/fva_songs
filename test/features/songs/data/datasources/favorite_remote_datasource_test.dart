import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/data/datasources/favorite_remote_datasource.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('utilisateur connecté', () {
    late MockFirebaseAuth auth;
    late FavoriteRemoteDataSource dataSource;

    setUp(() {
      auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', isAnonymous: true),
      );
      dataSource = FavoriteRemoteDataSource(firestore: firestore, auth: auth);
    });

    test('addFavorite crée le document sous users/{uid}/favorites', () async {
      await dataSource.addFavorite('song-1');

      final doc = await firestore
          .collection('users')
          .doc('uid-1')
          .collection('favorites')
          .doc('song-1')
          .get();
      expect(doc.exists, isTrue);
    });

    test(
      'watchFavoriteIds renvoie les ids favoris de l\'utilisateur',
      () async {
        await dataSource.addFavorite('song-1');
        await dataSource.addFavorite('song-2');

        final ids = await dataSource.watchFavoriteIds().first;

        expect(ids, {'song-1', 'song-2'});
      },
    );

    test('removeFavorite supprime le document', () async {
      await dataSource.addFavorite('song-1');
      await dataSource.removeFavorite('song-1');

      final ids = await dataSource.watchFavoriteIds().first;
      expect(ids, isEmpty);
    });
  });

  group('sans utilisateur connecté', () {
    test('lève une StateError sur toute opération', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final dataSource = FavoriteRemoteDataSource(
        firestore: firestore,
        auth: auth,
      );

      await expectLater(dataSource.addFavorite('song-1'), throwsStateError);
    });
  });
}
