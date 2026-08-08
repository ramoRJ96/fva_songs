import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Source de données des favoris : `users/{uid}/favorites/{songId}`.
class FavoriteRemoteDataSource {
  FavoriteRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Utilisateur anonyme requis pour les favoris.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _favorites =>
      _firestore.collection('users').doc(_uid).collection('favorites');

  Stream<Set<String>> watchFavoriteIds() {
    return _favorites.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
        );
  }

  Future<void> addFavorite(String songId) async {
    await _favorites.doc(songId).set({
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String songId) async {
    await _favorites.doc(songId).delete();
  }
}
