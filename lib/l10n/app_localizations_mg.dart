// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get appTitle => 'FVA Songs';

  @override
  String get navSongs => 'Hira';

  @override
  String get navFavorites => 'Tiana';

  @override
  String get navAdd => 'Hanampy';

  @override
  String get searchHint => 'Hitady hira...';

  @override
  String get allSongs => 'Ny hira rehetra';

  @override
  String resultsCount(int count) {
    return 'Valiny $count';
  }

  @override
  String get filterAll => 'Rehetra';

  @override
  String get filterTitle => 'Lohateny';

  @override
  String get filterNumber => 'Laharana';

  @override
  String get filterAuthor => 'Mpanoratra';

  @override
  String get filterTheme => 'Lohahevitra';

  @override
  String get filterKey => 'Feo';

  @override
  String get filterLanguage => 'Fiteny';

  @override
  String get filterFavorites => 'Tiana';

  @override
  String get emptySongsTitle => 'Tsy misy hira hita';

  @override
  String get emptySongsSubtitle => 'Andramo teny hafa na sivana hafa';

  @override
  String get emptyFavoritesTitle => 'Tsy mbola misy tiana';

  @override
  String get emptyFavoritesSubtitle =>
      'Ampidiro amin\'ny tiana ny hira amin\'ny alalan\'ny kintana.';

  @override
  String get songNotFound => 'Tsy hita ny hira';

  @override
  String get songDoesNotExist => 'Tsy misy io hira io.';

  @override
  String get verseOfTheDay => 'ANDININY ANDROANY';

  @override
  String get myFavorites => 'Ny tiako';

  @override
  String get tabFavorites => 'Tiana';

  @override
  String get tabWorshipLists => 'Lisitra fivavahana';

  @override
  String get savedTitles => 'LOHATENY VOATAHIRY';

  @override
  String songsCount(int count) {
    return 'Hira $count';
  }

  @override
  String get removeFavorite => 'Esory amin\'ny tiana';

  @override
  String get editorTitle => 'Mpanova hira';

  @override
  String get editorSubtitle => 'Mamorona ny tononkira sy ny antsipiriany.';

  @override
  String get fieldTitle => 'LOHATENY';

  @override
  String get fieldNumber => 'LAHARANA';

  @override
  String get fieldAuthor => 'MPANORATRA';

  @override
  String get fieldTheme => 'LOHAHEVITRA';

  @override
  String get fieldKey => 'FEO';

  @override
  String get fieldLanguage => 'FITENY';

  @override
  String get hintTitle => 'oh: Andriamanitra lehibe';

  @override
  String get hintNumber => 'oh: 124';

  @override
  String get hintAuthor => 'Mpanoratra na mpamorona';

  @override
  String get hintTheme => 'oh: Fanompoana, Fahasoavana...';

  @override
  String get hintKey => 'oh: G maj, D min...';

  @override
  String get languageFrench => 'Frantsay';

  @override
  String get languageMalagasy => 'Malagasy';

  @override
  String get addCouplet => 'Andininy';

  @override
  String get addRefrain => 'Refrain';

  @override
  String get addChorus => 'Chorus';

  @override
  String coupletLabel(int index) {
    return 'Andininy $index';
  }

  @override
  String get refrainLabel => 'Refrain';

  @override
  String get chorusLabel => 'Chorus';

  @override
  String get hintCouplet => 'Soraty eto ny tononkira...';

  @override
  String get hintRefrain => 'Soraty eto ny refrain...';

  @override
  String get hintChorus => 'Soraty eto ny chorus (tiana)...';

  @override
  String get publish => 'Tehirizo ny hira';

  @override
  String get publishing => 'Tehirizina...';

  @override
  String get publishNote =>
      'Azo ampiasaina ivelan\'ny aterineto ny hira aorian\'ny sync.';

  @override
  String get publishSuccessTitle => 'Voatahiry ny hira!';

  @override
  String get publishSuccessBody =>
      'Voatahiry ny hira ary hifanaraka amin\'i FVA Songs.';

  @override
  String get validationTitleRequired => 'Ilaina ny lohateny.';

  @override
  String get validationSectionRequired =>
      'Ampidiro farafahakeliny fizarana iray misy tononkira.';

  @override
  String get ok => 'OK';

  @override
  String get switchLanguage => 'Hanova fiteny';

  @override
  String get loadingSongs => 'Loading ny hira...';

  @override
  String get errorLoadingSongs => 'Tsy afaka naka ny hira.';

  @override
  String get sanctuaryModeSoon => 'Mode projection — ho avy tsy ho ela';

  @override
  String get projectionMode => 'Projection';

  @override
  String get authorLabel => 'Mpanoratra';

  @override
  String get keyLabel => 'Feo';
}
