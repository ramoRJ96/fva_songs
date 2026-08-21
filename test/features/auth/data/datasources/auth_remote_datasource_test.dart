import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/auth/data/datasources/auth_remote_datasource.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('isCurrentUserAdmin', () {
    test('false si aucun utilisateur connecté', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final dataSource = AuthRemoteDataSource(auth: auth, firestore: firestore);

      expect(await dataSource.isCurrentUserAdmin(), isFalse);
    });

    test('false si l\'utilisateur est anonyme', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-anon', isAnonymous: true),
      );
      final dataSource = AuthRemoteDataSource(auth: auth, firestore: firestore);

      expect(await dataSource.isCurrentUserAdmin(), isFalse);
    });

    test('false si l\'email n\'est pas dans config/admins ni admins/{uid}', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'uid-unknown',
          isAnonymous: false,
          email: 'inconnu@mail.com',
        ),
      );
      final dataSource = AuthRemoteDataSource(auth: auth, firestore: firestore);

      expect(await dataSource.isCurrentUserAdmin(), isFalse);
    });

    test('true si un document admins/{uid} existe', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'uid-doc',
          isAnonymous: false,
          email: 'autre@mail.com',
        ),
      );
      await firestore.collection('admins').doc('uid-doc').set({
        'role': 'admin',
      });
      final dataSource = AuthRemoteDataSource(auth: auth, firestore: firestore);

      expect(await dataSource.isCurrentUserAdmin(), isTrue);
    });

    test('true si l\'email figure dans config/admins.emails', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'uid-config',
          isAnonymous: false,
          email: 'config@mail.com',
        ),
      );
      await firestore.collection('config').doc('admins').set({
        'emails': ['config@mail.com'],
      });
      final dataSource = AuthRemoteDataSource(auth: auth, firestore: firestore);

      expect(await dataSource.isCurrentUserAdmin(), isTrue);
    });

    test('false si aucune condition admin n\'est remplie', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'uid-basique',
          isAnonymous: false,
          email: 'basique@mail.com',
        ),
      );
      final dataSource = AuthRemoteDataSource(auth: auth, firestore: firestore);

      expect(await dataSource.isCurrentUserAdmin(), isFalse);
    });
  });

  group('signOutToAnonymous', () {
    test('déconnecte puis reconnecte anonymement', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', isAnonymous: false),
      );
      final dataSource = AuthRemoteDataSource(auth: auth, firestore: firestore);

      // Le mock ne fournit qu'un seul utilisateur fixe : on le retire pour
      // que la reconnexion anonyme puisse générer un utilisateur anonyme.
      auth.mockUser = null;
      await dataSource.signOutToAnonymous();

      expect(dataSource.isAnonymous, isTrue);
      expect(dataSource.currentUser, isNotNull);
    });
  });

  group('signInWithEmail', () {
    test('authentifie l\'utilisateur', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final dataSource = AuthRemoteDataSource(auth: auth, firestore: firestore);

      await dataSource.signInWithEmail(
        email: '  admin@mail.com  ',
        password: 'secret',
      );

      expect(dataSource.currentUser, isNotNull);
      expect(dataSource.isAnonymous, isFalse);
    });
  });
}
