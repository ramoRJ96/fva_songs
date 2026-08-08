import 'song.dart';

/// Type de proposition soumise à validation admin.
enum SubmissionType {
  create,
  update;

  static SubmissionType fromString(String? value) {
    if (value == 'update') return SubmissionType.update;
    return SubmissionType.create;
  }
}

/// Statut de modération d'une soumission.
enum SubmissionStatus {
  pending,
  approved,
  rejected;

  static SubmissionStatus fromString(String? value) {
    switch (value) {
      case 'approved':
        return SubmissionStatus.approved;
      case 'rejected':
        return SubmissionStatus.rejected;
      case 'pending':
      default:
        return SubmissionStatus.pending;
    }
  }
}

/// Proposition d'ajout ou de modification d'un chant (en attente de validation).
class SongSubmission {
  const SongSubmission({
    required this.id,
    required this.type,
    required this.status,
    required this.createdBy,
    required this.payload,
    this.targetSongId,
    this.createdAt,
  });

  final String id;
  final SubmissionType type;
  final SubmissionStatus status;
  final String createdBy;

  /// Contenu proposé (id vide pour un create).
  final Song payload;

  /// Id du chant existant à modifier (uniquement pour [SubmissionType.update]).
  final String? targetSongId;

  final DateTime? createdAt;

  bool get isPending => status == SubmissionStatus.pending;
}
