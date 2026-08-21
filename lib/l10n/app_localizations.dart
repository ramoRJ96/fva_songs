import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('mg'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'FVA Songs'**
  String get appTitle;

  /// No description provided for @navSongs.
  ///
  /// In fr, this message translates to:
  /// **'Chants'**
  String get navSongs;

  /// No description provided for @navFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get navFavorites;

  /// No description provided for @navAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get navAdd;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un cantique...'**
  String get searchHint;

  /// No description provided for @allSongs.
  ///
  /// In fr, this message translates to:
  /// **'Tous les chants'**
  String get allSongs;

  /// No description provided for @resultsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} résultat(s)'**
  String resultsCount(int count);

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get filterAll;

  /// No description provided for @filterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get filterTitle;

  /// No description provided for @filterNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro'**
  String get filterNumber;

  /// No description provided for @filterAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Auteur'**
  String get filterAuthor;

  /// No description provided for @filterTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get filterTheme;

  /// No description provided for @filterKey.
  ///
  /// In fr, this message translates to:
  /// **'Tonalité'**
  String get filterKey;

  /// No description provided for @filterLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get filterLanguage;

  /// No description provided for @filterFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get filterFavorites;

  /// No description provided for @emptySongsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun chant trouvé'**
  String get emptySongsTitle;

  /// No description provided for @emptySongsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre terme ou filtre'**
  String get emptySongsSubtitle;

  /// No description provided for @emptyFavoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori pour le moment'**
  String get emptyFavoritesTitle;

  /// No description provided for @emptyFavoritesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des chants à vos favoris en cliquant sur l\'étoile.'**
  String get emptyFavoritesSubtitle;

  /// No description provided for @songNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Chant introuvable'**
  String get songNotFound;

  /// No description provided for @songDoesNotExist.
  ///
  /// In fr, this message translates to:
  /// **'Ce chant n\'existe pas.'**
  String get songDoesNotExist;

  /// No description provided for @myFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get myFavorites;

  /// No description provided for @savedTitles.
  ///
  /// In fr, this message translates to:
  /// **'TITRES ENREGISTRÉS'**
  String get savedTitles;

  /// No description provided for @songsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} chants'**
  String songsCount(int count);

  /// No description provided for @removeFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get removeFavorite;

  /// No description provided for @editorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Éditeur de cantique'**
  String get editorTitle;

  /// No description provided for @editorSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez les paroles et métadonnées du chant.'**
  String get editorSubtitle;

  /// No description provided for @fieldTitle.
  ///
  /// In fr, this message translates to:
  /// **'TITRE'**
  String get fieldTitle;

  /// No description provided for @fieldNumber.
  ///
  /// In fr, this message translates to:
  /// **'NUMÉRO'**
  String get fieldNumber;

  /// No description provided for @fieldAuthor.
  ///
  /// In fr, this message translates to:
  /// **'AUTEUR'**
  String get fieldAuthor;

  /// No description provided for @fieldTheme.
  ///
  /// In fr, this message translates to:
  /// **'THÈME'**
  String get fieldTheme;

  /// No description provided for @fieldKey.
  ///
  /// In fr, this message translates to:
  /// **'TONALITÉ'**
  String get fieldKey;

  /// No description provided for @fieldLanguage.
  ///
  /// In fr, this message translates to:
  /// **'LANGUE'**
  String get fieldLanguage;

  /// No description provided for @hintTitle.
  ///
  /// In fr, this message translates to:
  /// **'ex: Grand Dieu, nous te bénissons'**
  String get hintTitle;

  /// No description provided for @hintNumber.
  ///
  /// In fr, this message translates to:
  /// **'ex: 124'**
  String get hintNumber;

  /// No description provided for @hintAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Auteur original ou compositeur'**
  String get hintAuthor;

  /// No description provided for @hintTheme.
  ///
  /// In fr, this message translates to:
  /// **'ex: Adoration, Grâce...'**
  String get hintTheme;

  /// No description provided for @hintKey.
  ///
  /// In fr, this message translates to:
  /// **'ex: G maj, D min...'**
  String get hintKey;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageMalagasy.
  ///
  /// In fr, this message translates to:
  /// **'Malagasy'**
  String get languageMalagasy;

  /// No description provided for @addCouplet.
  ///
  /// In fr, this message translates to:
  /// **'Couplet'**
  String get addCouplet;

  /// No description provided for @addRefrain.
  ///
  /// In fr, this message translates to:
  /// **'Refrain'**
  String get addRefrain;

  /// No description provided for @addChorus.
  ///
  /// In fr, this message translates to:
  /// **'Chorus'**
  String get addChorus;

  /// No description provided for @coupletLabel.
  ///
  /// In fr, this message translates to:
  /// **'Couplet {index}'**
  String coupletLabel(int index);

  /// No description provided for @refrainLabel.
  ///
  /// In fr, this message translates to:
  /// **'Refrain'**
  String get refrainLabel;

  /// No description provided for @chorusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Chorus'**
  String get chorusLabel;

  /// No description provided for @hintCouplet.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez les paroles du couplet...'**
  String get hintCouplet;

  /// No description provided for @hintRefrain.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez les paroles du refrain...'**
  String get hintRefrain;

  /// No description provided for @hintChorus.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez les paroles du chorus (optionnel)...'**
  String get hintChorus;

  /// No description provided for @publish.
  ///
  /// In fr, this message translates to:
  /// **'Proposer le chant'**
  String get publish;

  /// No description provided for @publishing.
  ///
  /// In fr, this message translates to:
  /// **'Envoi...'**
  String get publishing;

  /// No description provided for @publishNote.
  ///
  /// In fr, this message translates to:
  /// **'Votre proposition sera validée par un administrateur avant d\'apparaître dans le catalogue.'**
  String get publishNote;

  /// No description provided for @publishNoteAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Connecté en admin : le chant sera publié immédiatement.'**
  String get publishNoteAdmin;

  /// No description provided for @publishSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cantique publié !'**
  String get publishSuccessTitle;

  /// No description provided for @publishSuccessBody.
  ///
  /// In fr, this message translates to:
  /// **'Le chant est maintenant visible dans le catalogue.'**
  String get publishSuccessBody;

  /// No description provided for @submitPendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Proposition envoyée !'**
  String get submitPendingTitle;

  /// No description provided for @submitPendingBody.
  ///
  /// In fr, this message translates to:
  /// **'Merci. Un administrateur validera l\'ajout ou la modification avant publication.'**
  String get submitPendingBody;

  /// No description provided for @submitEdit.
  ///
  /// In fr, this message translates to:
  /// **'Proposer la modification'**
  String get submitEdit;

  /// No description provided for @editorEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le cantique'**
  String get editorEditTitle;

  /// No description provided for @editorEditSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les changements seront soumis à validation (sauf admin).'**
  String get editorEditSubtitle;

  /// No description provided for @editSong.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editSong;

  /// No description provided for @validationTitleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le titre est obligatoire.'**
  String get validationTitleRequired;

  /// No description provided for @validationSectionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins une section avec des paroles.'**
  String get validationSectionRequired;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @switchLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Changer de langue'**
  String get switchLanguage;

  /// No description provided for @loadingSongs.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des chants...'**
  String get loadingSongs;

  /// No description provided for @errorLoadingSongs.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les chants.'**
  String get errorLoadingSongs;

  /// No description provided for @sanctuaryModeSoon.
  ///
  /// In fr, this message translates to:
  /// **'Mode projection — bientôt disponible'**
  String get sanctuaryModeSoon;

  /// No description provided for @screenStayOnActive.
  ///
  /// In fr, this message translates to:
  /// **'L\'écran reste allumé pendant l\'affichage des paroles.'**
  String get screenStayOnActive;

  /// No description provided for @fontSizeSmall.
  ///
  /// In fr, this message translates to:
  /// **'Petite'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get fontSizeNormal;

  /// No description provided for @fontSizeLarge.
  ///
  /// In fr, this message translates to:
  /// **'Grande'**
  String get fontSizeLarge;

  /// No description provided for @projectionMode.
  ///
  /// In fr, this message translates to:
  /// **'Projection'**
  String get projectionMode;

  /// No description provided for @authorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Auteur'**
  String get authorLabel;

  /// No description provided for @keyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tonalité'**
  String get keyLabel;

  /// No description provided for @adminAccess.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminAccess;

  /// No description provided for @adminLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion admin'**
  String get adminLoginTitle;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour valider les ajouts et modifications.'**
  String get adminLoginSubtitle;

  /// No description provided for @adminEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get adminEmail;

  /// No description provided for @adminPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get adminPassword;

  /// No description provided for @adminSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get adminSignIn;

  /// No description provided for @adminSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get adminSignOut;

  /// No description provided for @adminLoginFieldsRequired.
  ///
  /// In fr, this message translates to:
  /// **'E-mail et mot de passe requis.'**
  String get adminLoginFieldsRequired;

  /// No description provided for @adminLoginFailed.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants incorrects.'**
  String get adminLoginFailed;

  /// No description provided for @adminLoginTooMany.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez plus tard.'**
  String get adminLoginTooMany;

  /// No description provided for @adminNotAuthorized.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte n\'est pas administrateur.'**
  String get adminNotAuthorized;

  /// No description provided for @moderationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Validation'**
  String get moderationTitle;

  /// No description provided for @moderationEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune proposition en attente'**
  String get moderationEmptyTitle;

  /// No description provided for @moderationEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les ajouts et modifications soumis par les utilisateurs apparaîtront ici.'**
  String get moderationEmptySubtitle;

  /// No description provided for @moderationTypeCreate.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel ajout'**
  String get moderationTypeCreate;

  /// No description provided for @moderationTypeUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Modification'**
  String get moderationTypeUpdate;

  /// No description provided for @moderationApprove.
  ///
  /// In fr, this message translates to:
  /// **'Approuver'**
  String get moderationApprove;

  /// No description provided for @moderationReject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get moderationReject;

  /// No description provided for @moderationDiffCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Actuel'**
  String get moderationDiffCurrent;

  /// No description provided for @moderationDiffProposed.
  ///
  /// In fr, this message translates to:
  /// **'Proposé'**
  String get moderationDiffProposed;

  /// No description provided for @moderationDiffLyrics.
  ///
  /// In fr, this message translates to:
  /// **'Paroles'**
  String get moderationDiffLyrics;

  /// No description provided for @moderationUnchanged.
  ///
  /// In fr, this message translates to:
  /// **'Inchangé'**
  String get moderationUnchanged;

  /// No description provided for @moderationCurrentMissing.
  ///
  /// In fr, this message translates to:
  /// **'Le chant actuel n\'est plus dans le catalogue. Aperçu de la proposition uniquement.'**
  String get moderationCurrentMissing;

  /// No description provided for @mySubmissionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes propositions'**
  String get mySubmissionsTitle;

  /// No description provided for @mySubmissionsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune proposition'**
  String get mySubmissionsEmptyTitle;

  /// No description provided for @mySubmissionsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos ajouts et modifications soumis apparaîtront ici.'**
  String get mySubmissionsEmptySubtitle;

  /// No description provided for @submissionStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get submissionStatusPending;

  /// No description provided for @submissionStatusApproved.
  ///
  /// In fr, this message translates to:
  /// **'Approuvée'**
  String get submissionStatusApproved;

  /// No description provided for @submissionStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get submissionStatusRejected;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour disponible'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'La version {version} est disponible. Téléchargez-la pour mettre à jour l\'application (vos données seront conservées).'**
  String updateAvailableMessage(String version);

  /// No description provided for @updateDownloadButton.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get updateDownloadButton;

  /// No description provided for @updateLaterButton.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get updateLaterButton;

  /// No description provided for @aboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutTitle;

  /// No description provided for @aboutAuthorName.
  ///
  /// In fr, this message translates to:
  /// **'Moïse'**
  String get aboutAuthorName;

  /// No description provided for @aboutAuthorRole.
  ///
  /// In fr, this message translates to:
  /// **'Développeur · 6 ans d\'expérience'**
  String get aboutAuthorRole;

  /// No description provided for @aboutBody.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai créé FVA Songs pour aider notre église à retrouver rapidement un chant, ainsi que la tonalité de référence pour tous les musiciens.'**
  String get aboutBody;

  /// No description provided for @aboutDonateTitle.
  ///
  /// In fr, this message translates to:
  /// **'SOUTENIR'**
  String get aboutDonateTitle;

  /// No description provided for @aboutDonateBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'application est gratuite. Pour un don, contactez-moi :'**
  String get aboutDonateBody;

  /// No description provided for @aboutContactEmail.
  ///
  /// In fr, this message translates to:
  /// **'moiseraidjy@gmail.com'**
  String get aboutContactEmail;

  /// No description provided for @aboutContactWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp · 034 25 228 31'**
  String get aboutContactWhatsApp;

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
