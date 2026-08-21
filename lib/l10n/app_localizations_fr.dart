// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FVA Songs';

  @override
  String get navSongs => 'Chants';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navAdd => 'Ajouter';

  @override
  String get searchHint => 'Rechercher un cantique...';

  @override
  String get allSongs => 'Tous les chants';

  @override
  String resultsCount(int count) {
    return '$count résultat(s)';
  }

  @override
  String get filterAll => 'Tout';

  @override
  String get filterTitle => 'Titre';

  @override
  String get filterNumber => 'Numéro';

  @override
  String get filterAuthor => 'Auteur';

  @override
  String get filterTheme => 'Thème';

  @override
  String get filterKey => 'Tonalité';

  @override
  String get filterLanguage => 'Langue';

  @override
  String get filterFavorites => 'Favoris';

  @override
  String get emptySongsTitle => 'Aucun chant trouvé';

  @override
  String get emptySongsSubtitle => 'Essayez un autre terme ou filtre';

  @override
  String get emptyFavoritesTitle => 'Aucun favori pour le moment';

  @override
  String get emptyFavoritesSubtitle =>
      'Ajoutez des chants à vos favoris en cliquant sur l\'étoile.';

  @override
  String get songNotFound => 'Chant introuvable';

  @override
  String get songDoesNotExist => 'Ce chant n\'existe pas.';

  @override
  String get verseOfTheDay => 'VERSET DU JOUR';

  @override
  String get myFavorites => 'Mes favoris';

  @override
  String get tabFavorites => 'Favoris';

  @override
  String get tabWorshipLists => 'Listes de culte';

  @override
  String get savedTitles => 'TITRES ENREGISTRÉS';

  @override
  String songsCount(int count) {
    return '$count chants';
  }

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get editorTitle => 'Éditeur de cantique';

  @override
  String get editorSubtitle => 'Créez les paroles et métadonnées du chant.';

  @override
  String get fieldTitle => 'TITRE';

  @override
  String get fieldNumber => 'NUMÉRO';

  @override
  String get fieldAuthor => 'AUTEUR';

  @override
  String get fieldTheme => 'THÈME';

  @override
  String get fieldKey => 'TONALITÉ';

  @override
  String get fieldLanguage => 'LANGUE';

  @override
  String get hintTitle => 'ex: Grand Dieu, nous te bénissons';

  @override
  String get hintNumber => 'ex: 124';

  @override
  String get hintAuthor => 'Auteur original ou compositeur';

  @override
  String get hintTheme => 'ex: Adoration, Grâce...';

  @override
  String get hintKey => 'ex: G maj, D min...';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageMalagasy => 'Malagasy';

  @override
  String get addCouplet => 'Couplet';

  @override
  String get addRefrain => 'Refrain';

  @override
  String get addChorus => 'Chorus';

  @override
  String coupletLabel(int index) {
    return 'Couplet $index';
  }

  @override
  String get refrainLabel => 'Refrain';

  @override
  String get chorusLabel => 'Chorus';

  @override
  String get hintCouplet => 'Saisissez les paroles du couplet...';

  @override
  String get hintRefrain => 'Saisissez les paroles du refrain...';

  @override
  String get hintChorus => 'Saisissez les paroles du chorus (optionnel)...';

  @override
  String get publish => 'Proposer le chant';

  @override
  String get publishing => 'Envoi...';

  @override
  String get publishNote =>
      'Votre proposition sera validée par un administrateur avant d\'apparaître dans le catalogue.';

  @override
  String get publishNoteAdmin =>
      'Connecté en admin : le chant sera publié immédiatement.';

  @override
  String get publishSuccessTitle => 'Cantique publié !';

  @override
  String get publishSuccessBody =>
      'Le chant est maintenant visible dans le catalogue.';

  @override
  String get submitPendingTitle => 'Proposition envoyée !';

  @override
  String get submitPendingBody =>
      'Merci. Un administrateur validera l\'ajout ou la modification avant publication.';

  @override
  String get submitEdit => 'Proposer la modification';

  @override
  String get editorEditTitle => 'Modifier le cantique';

  @override
  String get editorEditSubtitle =>
      'Les changements seront soumis à validation (sauf admin).';

  @override
  String get editSong => 'Modifier';

  @override
  String get validationTitleRequired => 'Le titre est obligatoire.';

  @override
  String get validationSectionRequired =>
      'Ajoutez au moins une section avec des paroles.';

  @override
  String get ok => 'OK';

  @override
  String get switchLanguage => 'Changer de langue';

  @override
  String get loadingSongs => 'Chargement des chants...';

  @override
  String get errorLoadingSongs => 'Impossible de charger les chants.';

  @override
  String get sanctuaryModeSoon => 'Mode projection — bientôt disponible';

  @override
  String get screenStayOnActive =>
      'L\'écran reste allumé pendant l\'affichage des paroles.';

  @override
  String get projectionMode => 'Projection';

  @override
  String get authorLabel => 'Auteur';

  @override
  String get keyLabel => 'Tonalité';

  @override
  String get adminAccess => 'Administration';

  @override
  String get adminLoginTitle => 'Connexion admin';

  @override
  String get adminLoginSubtitle =>
      'Connectez-vous pour valider les ajouts et modifications.';

  @override
  String get adminEmail => 'E-mail';

  @override
  String get adminPassword => 'Mot de passe';

  @override
  String get adminSignIn => 'Se connecter';

  @override
  String get adminSignOut => 'Déconnexion';

  @override
  String get adminLoginFieldsRequired => 'E-mail et mot de passe requis.';

  @override
  String get adminLoginFailed => 'Identifiants incorrects.';

  @override
  String get adminLoginTooMany => 'Trop de tentatives. Réessayez plus tard.';

  @override
  String get adminNotAuthorized => 'Ce compte n\'est pas administrateur.';

  @override
  String get moderationTitle => 'Validation';

  @override
  String get moderationEmptyTitle => 'Aucune proposition en attente';

  @override
  String get moderationEmptySubtitle =>
      'Les ajouts et modifications soumis par les utilisateurs apparaîtront ici.';

  @override
  String get moderationTypeCreate => 'Nouvel ajout';

  @override
  String get moderationTypeUpdate => 'Modification';

  @override
  String get moderationApprove => 'Approuver';

  @override
  String get moderationReject => 'Refuser';

  @override
  String get moderationDiffCurrent => 'Actuel';

  @override
  String get moderationDiffProposed => 'Proposé';

  @override
  String get moderationDiffLyrics => 'Paroles';

  @override
  String get moderationUnchanged => 'Inchangé';

  @override
  String get moderationCurrentMissing =>
      'Le chant actuel n\'est plus dans le catalogue. Aperçu de la proposition uniquement.';

  @override
  String get mySubmissionsTitle => 'Mes propositions';

  @override
  String get mySubmissionsEmptyTitle => 'Aucune proposition';

  @override
  String get mySubmissionsEmptySubtitle =>
      'Vos ajouts et modifications soumis apparaîtront ici.';

  @override
  String get submissionStatusPending => 'En attente';

  @override
  String get submissionStatusApproved => 'Approuvée';

  @override
  String get submissionStatusRejected => 'Refusée';

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String updateAvailableMessage(String version) {
    return 'La version $version est disponible. Téléchargez-la pour mettre à jour l\'application (vos données seront conservées).';
  }

  @override
  String get updateDownloadButton => 'Télécharger';

  @override
  String get updateLaterButton => 'Plus tard';
}
