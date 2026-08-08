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
  String get publish => 'Enregistrer le chant';

  @override
  String get publishing => 'Enregistrement...';

  @override
  String get publishNote =>
      'Le chant sera disponible hors ligne après synchronisation.';

  @override
  String get publishSuccessTitle => 'Cantique enregistré !';

  @override
  String get publishSuccessBody =>
      'Le chant a été sauvegardé et sera synchronisé avec FVA Songs.';

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
  String get projectionMode => 'Projection';

  @override
  String get authorLabel => 'Auteur';

  @override
  String get keyLabel => 'Tonalité';
}
