import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/song.dart';
import '../models/song_model.dart';

/// Source de données Firestore pour les chants.
///
/// Isolation de l'API Firebase (DIP) : les repositories ne parlent qu'à cette classe.
class SongRemoteDataSource {
  SongRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _songs =>
      _firestore.collection('songs');

  Stream<List<Song>> watchSongs() {
    // orderBy peut échouer si certains docs n'ont pas le champ ; on trie en mémoire.
    return _songs.snapshots().map((snapshot) {
      final songs = snapshot.docs
          .map((doc) => SongModel.fromFirestore(doc.id, doc.data()).song)
          .toList()
        ..sort((a, b) => a.number.compareTo(b.number));
      return songs;
    });
  }

  Future<Song?> getById(String id) async {
    final doc = await _songs.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return SongModel.fromFirestore(doc.id, doc.data()!).song;
  }

  Future<Song> addSong(Song song) async {
    final searchText = SongModel.buildSearchText(song);
    final toSave = song.copyWith(searchText: searchText);
    final docRef = await _songs.add(SongModel(toSave).toFirestore());
    return toSave.copyWith(id: docRef.id);
  }

  Future<void> updateSong(Song song) async {
    final toSave = song.copyWith(searchText: SongModel.buildSearchText(song));
    await _songs.doc(song.id).set(
          SongModel(toSave).toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteSong(String id) async {
    await _songs.doc(id).delete();
  }
}
