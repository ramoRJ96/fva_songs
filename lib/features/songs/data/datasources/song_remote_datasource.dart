import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/song.dart';
import '../../domain/services/song_number_comparator.dart';
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

  /// Catalogue public : chants approuvés, **sans paroles** (lazy : le détail
  /// charge les sections via [getById]). La recherche reste possible via
  /// `searchText`.
  ///
  /// Filtre Firestore `status == approved` (index champ unique, pas d'index
  /// composite). Le tri `number` reste côté client.
  Stream<List<Song>> watchSongs() {
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;
    late final StreamController<List<Song>> controller;
    Timer? retryTimer;

    void listenApproved() {
      sub?.cancel();
      sub = _songs
          .where('status', isEqualTo: SongStatus.approved.name)
          .snapshots()
          .listen(
        (snapshot) {
          final songs = snapshot.docs
              .map(
                (doc) => SongModel.fromFirestore(
                  doc.id,
                  doc.data(),
                  includeSections: false,
                ).song,
              )
              .toList()
            ..sort((a, b) => SongNumberComparator.compare(a.number, b.number));
          controller.add(songs);
        },
        onError: (Object error, StackTrace stack) {
          if (error is FirebaseException && error.code == 'permission-denied') {
            retryTimer?.cancel();
            retryTimer = Timer(const Duration(milliseconds: 400), () {
              if (!controller.isClosed) listenApproved();
            });
            return;
          }
          controller.addError(error, stack);
        },
      );
    }

    controller = StreamController<List<Song>>(
      onListen: listenApproved,
      onCancel: () async {
        retryTimer?.cancel();
        await sub?.cancel();
      },
    );
    return controller.stream;
  }

  /// Chant complet. Lecture **cache d'abord** (le snapshot catalogue a déjà
  /// peuplé le cache disque, paroles comprises), puis réseau si besoin.
  Future<Song?> getById(String id) async {
    final doc = await _getPreferCache(_songs.doc(id));
    if (!doc.exists || doc.data() == null) return null;
    final song = SongModel.fromFirestore(doc.id, doc.data()!).song;
    if (song.status != SongStatus.approved) return null;
    return song;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getPreferCache(
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    try {
      final cached = await docRef.get(const GetOptions(source: Source.cache));
      if (cached.exists) return cached;
    } catch (_) {
      // Cache vide, fake Firestore, ou indisponible → get() standard.
    }
    return docRef.get();
  }

  /// Publication directe (admin) — chant visible immédiatement.
  Future<Song> addApprovedSong(Song song) async {
    final searchText = SongModel.buildSearchText(song);
    final toSave = song.copyWith(
      searchText: searchText,
      status: SongStatus.approved,
    );
    final docRef = await _songs.add(SongModel(toSave).toFirestore());
    return toSave.copyWith(id: docRef.id);
  }

  @Deprecated('Utiliser addApprovedSong (admin) ou les soumissions')
  Future<Song> addSong(Song song) => addApprovedSong(song);

  Future<void> updateSong(Song song) async {
    final toSave = song.copyWith(
      searchText: SongModel.buildSearchText(song),
      status: SongStatus.approved,
    );
    await _songs.doc(song.id).set(
          SongModel(toSave).toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteSong(String id) async {
    await _songs.doc(id).delete();
  }
}
