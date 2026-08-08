import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/song.dart';
import '../../domain/entities/song_submission.dart';
import '../models/song_model.dart';
import '../models/song_submission_model.dart';
import 'song_remote_datasource.dart';

/// Source Firestore pour les soumissions de chants.
class SongSubmissionRemoteDataSource {
  SongSubmissionRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    SongRemoteDataSource? songs,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _songs = songs ?? SongRemoteDataSource(firestore: firestore);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SongRemoteDataSource _songs;

  CollectionReference<Map<String, dynamic>> get _submissions =>
      _firestore.collection('song_submissions');

  Stream<List<SongSubmission>> watchPending() {
    return _submissions.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SongSubmissionModel.fromFirestore(doc.id, doc.data()).submission)
          .where((s) => s.status == SubmissionStatus.pending)
          .toList()
        ..sort((a, b) {
          final aAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bAt.compareTo(aAt);
        });
      return list;
    });
  }

  Future<SongSubmission> submitCreate(Song song) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Utilisateur non authentifié');
    }

    final withSearch = song.copyWith(
      id: '',
      searchText: SongModel.buildSearchText(song),
    );
    final submission = SongSubmission(
      id: '',
      type: SubmissionType.create,
      status: SubmissionStatus.pending,
      createdBy: uid,
      payload: withSearch,
      createdAt: DateTime.now().toUtc(),
    );

    final docRef =
        await _submissions.add(SongSubmissionModel(submission).toFirestore());
    return SongSubmission(
      id: docRef.id,
      type: submission.type,
      status: submission.status,
      createdBy: submission.createdBy,
      payload: submission.payload,
      createdAt: submission.createdAt,
    );
  }

  Future<SongSubmission> submitUpdate({
    required String targetSongId,
    required Song song,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Utilisateur non authentifié');
    }

    final withSearch = song.copyWith(
      id: targetSongId,
      searchText: SongModel.buildSearchText(song),
    );
    final submission = SongSubmission(
      id: '',
      type: SubmissionType.update,
      status: SubmissionStatus.pending,
      createdBy: uid,
      targetSongId: targetSongId,
      payload: withSearch,
      createdAt: DateTime.now().toUtc(),
    );

    final docRef =
        await _submissions.add(SongSubmissionModel(submission).toFirestore());
    return SongSubmission(
      id: docRef.id,
      type: submission.type,
      status: submission.status,
      createdBy: submission.createdBy,
      targetSongId: submission.targetSongId,
      payload: submission.payload,
      createdAt: submission.createdAt,
    );
  }

  Future<void> approve(SongSubmission submission) async {
    if (submission.type == SubmissionType.create) {
      await _songs.addApprovedSong(submission.payload);
    } else {
      final targetId = submission.targetSongId;
      if (targetId == null || targetId.isEmpty) {
        throw StateError('Soumission update sans targetSongId');
      }
      await _songs.updateSong(submission.payload.copyWith(id: targetId));
    }

    await _submissions.doc(submission.id).set(
      {
        'status': SubmissionStatus.approved.name,
        'reviewedAt': DateTime.now().toUtc().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> reject(String submissionId) async {
    await _submissions.doc(submissionId).set(
      {
        'status': SubmissionStatus.rejected.name,
        'reviewedAt': DateTime.now().toUtc().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }
}
