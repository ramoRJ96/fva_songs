# FVA Songs — Spécification technique

**Version du document :** 1.6  
**Version de l’application :** 0.1.2+3  
**Date :** 18 août 2026  
**Statut :** source de vérité pour l’architecture, les fonctionnalités et les règles métier.

Ce document décrit le produit tel qu’il est implémenté. Toute évolution (nouvelle fonctionnalité, changement de schéma Firestore, nouveau rôle, nouvelle convention) doit mettre à jour ce fichier.

Les agents IA **lisent ce fichier avant toute modification** et le tiennent à jour dans le même changement — voir `AGENTS.md`.

---

## Table des matières

0. [Documentation du dépôt](#0-documentation-du-dépôt)
1. [Vision produit](#1-vision-produit)
2. [Acteurs et rôles](#2-acteurs-et-rôles)
3. [Périmètre fonctionnel](#3-périmètre-fonctionnel)
4. [Exigences non fonctionnelles](#4-exigences-non-fonctionnelles)
5. [Stack technique](#5-stack-technique)
6. [Architecture logicielle](#6-architecture-logicielle)
7. [Structure du dépôt](#7-structure-du-dépôt)
8. [Modèle métier (domaine)](#8-modèle-métier-domaine)
9. [Couche data et schéma Firestore](#9-couche-data-et-schéma-firestore)
10. [Règles de sécurité Firestore](#10-règles-de-sécurité-firestore)
11. [Authentification et autorisation](#11-authentification-et-autorisation)
12. [Flux de modération](#12-flux-de-modération)
13. [Recherche et filtrage](#13-recherche-et-filtrage)
14. [Navigation et écrans](#14-navigation-et-écrans)
15. [Gestion d’état (Riverpod)](#15-gestion-détat-riverpod)
16. [Hors-ligne (offline-first)](#16-hors-ligne-offline-first)
17. [Internationalisation](#17-internationalisation)
18. [Thème, branding et responsive](#18-thème-branding-et-responsive)
19. [Tests](#19-tests)
20. [Build, signature et distribution](#20-build-signature-et-distribution)
21. [Import du catalogue](#21-import-du-catalogue)
22. [Contraintes, limites et dettes connues](#22-contraintes-limites-et-dettes-connues)
23. [Évolutions envisagées](#23-évolutions-envisagées)
24. [Analytics (GA4)](#24-analytics-ga4)

---

## 0. Documentation du dépôt

| Fichier | Audience | Rôle |
| --- | --- | --- |
| `README.md` | Humains | Clone, setup Firebase, run, tests, deploy |
| `spec.md` | Humains + agents | Spec technique (ce fichier) — source de vérité produit / archi |
| `AGENTS.md` | Agents IA | Normes de travail : lire `spec.md` avant toute modif ; mettre à jour `spec.md` si le comportement change |

`AGENTS.md` ne recopie pas cette spec. Il impose le processus et les contraintes opérationnelles (Clean Architecture, git, secrets, tests).

---

## 1. Vision produit

FVA Songs (fihirana / recueil de cantiques) est une application mobile destinée au culte. Elle permet à n’importe quel fidèle de :

- consulter le catalogue de chants même **sans réseau** ;
- retrouver un chant en quelques secondes (numéro, titre, paroles, etc.) ;
- marquer des favoris ;
- proposer un **ajout** ou une **correction**.

La publication n’est **pas** ouverte. Toute contribution d’un utilisateur non administrateur transite par une file de modération. Seul un administrateur peut insérer ou modifier un chant dans le catalogue public.

L’interface est bilingue **français / malagasy**. La langue du contenu d’un chant (`Song.language`) est indépendante de la langue de l’UI.

Distribution actuelle : APK Android signé, téléchargeable depuis une landing page Firebase Hosting (hors Play Store).

**URL de téléchargement :** https://fvasongs-d8055.web.app  
**Projet Firebase :** `fvasongs-d8055`  
**Application ID Android :** `com.fva.songs`

---

## 2. Acteurs et rôles

| Rôle | Comment il est identifié | Droits |
| --- | --- | --- |
| **Utilisateur public** | Session Firebase Auth **anonyme**, créée au démarrage si aucune session n’existe. | Lire le catalogue `approved`, rechercher, favoris (scoped à son `uid`), soumettre un `create` / `update` en `pending`. |
| **Administrateur** | Session **email / mot de passe**. Le rôle est reconnu si (1) un document `admins/{uid}` existe, **ou** (2) l’e-mail figure dans `config/admins.emails`, **ou** (3) l’e-mail égale l’e-mail bootstrap `moiseraidjy@gmail.com`. | Tous les droits utilisateur + publication directe dans `songs` + lecture de toutes les soumissions + approve / reject. |
| **Console Firebase** | Opérateur humain hors app. | Seul moyen d’écrire `admins/{uid}` et `config/admins` (`allow write: if false` dans les rules). |

Règles importantes :

- Un utilisateur anonyme **n’est jamais** admin.
- La déconnexion admin (`signOutToAnonymous`) ne laisse pas l’app sans session : elle resigne anonymement pour que favoris et soumissions restent possibles.
- Les favoris sont liés au `uid` anonyme. Si l’utilisateur désinstalle l’app ou change de téléphone, les favoris ne sont pas transférés (pas de compte nominatif côté fidèle).

---

## 3. Périmètre fonctionnel

### 3.1 Catalogue

- Affichage de tous les chants dont `status == approved`.
- Tri par `number` via `SongNumberComparator` (ordre naturel : `2` avant `10`, `28` avant `28 bis`).
- Carte de chant : numéro, titre, première ligne, tonalité.
- Pull-to-refresh : invalide `songsCatalogProvider` et relit Firestore (cache + réseau).
- Grille responsive (1 / 2 / 3 colonnes selon la largeur).

### 3.2 Recherche et filtres

- Barre de recherche avec debounce **200 ms**.
- Chips de portée (`SearchScope`) : Tout, Titre, Numéro, Auteur, Thème, Tonalité, Langue, Favoris.
- Matching insensible à la casse et aux accents.
- Ranking de pertinence (voir §13).
- Compteur de résultats localisé.

### 3.3 Détail d’un chant

- AppBar : numéro + titre, bouton retour, bouton **Modifier**, bouton favori.
- Métadonnées (auteur, thème, tonalité, langue).
- Paroles via `song.sectionsForDisplay` (refrain/chorus après le 1er couplet).
- Contrôle de taille de police : 14–36 px, pas de ±2, défaut 22.
- **Wake lock** (`wakelock_plus`) : l’écran reste allumé tant que l’écran détail est ouvert (culte / lecture des paroles). Désactivé au `dispose`.
- État vide si l’id n’existe pas dans le catalogue chargé.

### 3.4 Favoris

- Stockage Firestore `users/{uid}/favorites/{songId}` (document vide + `createdAt`).
- Toggle depuis le détail (étoile) et retrait depuis la liste favoris.
- Écran Favoris = intersection catalogue ∩ ids favoris.
- Vide : message d’incitation.

### 3.5 Ajout / modification

Formulaire unique `AddSongScreen` :

- Champs : titre, numéro, auteur, thème, tonalité, langue du contenu (`fr` / `mg`).
- Sections dynamiques : couplets numérotés, refrain, chorus. Chaque section est un éditeur de texte multiligne.
- Mode création : un couplet + un refrain pré-créés.
- Mode édition : hydrate depuis le `Song` existant (`/edit/:id`).
- Validation UI : titre et au moins une ligne de paroles non vide (côté écran).
- `firstLine` calculé côté contrôleur : première ligne non vide, entourée de guillemets typographiques `« ` ` »`.
- Trim de tous les champs texte à l’enregistrement.

Résultat :

- Admin → `SongSaveOutcome.published` (écriture directe `songs`).
- Non-admin → `SongSaveOutcome.pendingReview` (document `song_submissions`).
- Modale de succès avec texte adapté (publié vs en attente de validation).
- Icône **historique** dans l’AppBar (mode création) → `/submissions` : liste des propositions de l’utilisateur courant (tous statuts).

### 3.6 Mes propositions

- Route `/submissions` (`MySubmissionsScreen`).
- Stream Firestore `song_submissions` filtré `createdBy == uid` (rules : lecture autorisée pour l’auteur).
- Affichage : type (create/update), statut (pending / approved / rejected), titre, numéro, firstLine, date.
- Tri client `createdAt` desc (plus récentes en premier).
- Vide : message d’incitation.

### 3.7 Administration

- Icône bouclier dans l’AppBar de la liste.
- Si déjà admin → `/admin`, sinon `/admin/login`.
- Login email + mot de passe. Après succès, vérification `isCurrentUserAdmin()` : si false, message d’erreur (compte Firebase Auth sans rôle admin).
- Écran de modération :
  - liste des soumissions `pending`, plus récentes en premier ;
  - aperçu du payload (métadonnées + paroles réordonnées) ;
  - distinction create / update ;
  - actions Approuver / Rejeter ;
  - bouton déconnexion.

### 3.8 Langue de l’UI

- Toggle FR ↔ MG dans l’AppBar (affiche le code courant : `FR` / `MG`).
- Persistance `SharedPreferences` clé `app_locale_code`.
- Défaut : français. Code inconnu → français.

### 3.9 Hors périmètre actuel (non implémenté)

Malgré quelques clés l10n héritées (`tabWorshipLists`, `verseOfTheDay`), **les listes de culte** et le **verset du jour** ne sont pas des fonctionnalités livrées.

Pas de Play Store, pas de TestFlight, pas de compte utilisateur nominatif pour les fidèles, pas de sync multi-appareils des favoris.

---

## 4. Exigences non fonctionnelles

| Critère | Cible / implémentation |
| --- | --- |
| Offline-first | Cache Firestore disque, taille illimitée. Lecture du catalogue depuis le cache si le réseau est absent. |
| Performance liste | Construction paresseuse (`SliverList` / `SliverGrid`, `ValueKey`, `cacheExtent` 480). Rebuilds isolés (AppBar / compteur / résultats). Catalogue en mémoire **sans paroles**. |
| Performance détail | `getById` lit le **cache Firestore d’abord** (le snapshot catalogue a déjà le document complet). `songDetailProvider` keepAlive 2 min. Paroles en `ListView.builder`. |
| Performance recherche | Filtrage 100 % in-memory. Debounce 200 ms. Query vide + scope ≠ favoris → même instance de liste (pas de rebuild inutile). |
| Performance 1er frame | Inter **embarqué** (`google_fonts/*.ttf`) ; `GoogleFonts.config.allowRuntimeFetching = false`. |
| Sécurité | Aucune écriture publique sur `songs`. Rules Firestore = source de vérité serveur. L’UI ne fait que refléter le rôle. |
| i18n | FR + MG pour l’UI. Fallback Material/Cupertino FR pour `mg` (locale non fournie par le SDK). |
| Responsive | Breakpoints 640 / 768 / 1024 / 1280 / 1536. NavigationBar vs NavigationRail. Largeur max du contenu. |
| Testabilité | Domain pur + DIP : 122 tests unitaires sans projet Firebase réel. |
| Distribution | APK signé, landing Hosting, pas de store. |
| Analytics | Firebase Analytics (GA4) — app mobile + landing Hosting. Pas de PII ; collecte à partir de l’activation (pas de données rétroactives). |

---

## 5. Stack technique

| Couche | Choix | Version / notes |
| --- | --- | --- |
| Framework | Flutter / Dart | SDK `^3.10.1`, Flutter 3.x stable |
| État | `flutter_riverpod` | `^2.6.1` (Provider, StateProvider, StreamProvider, StateNotifierProvider) |
| Navigation | `go_router` | `^15.1.2` |
| Backend | Firebase | Auth, Cloud Firestore, Hosting, **Analytics (GA4)** |
| Auth | `firebase_auth` | Anonyme + Email/Password |
| Données | `cloud_firestore` | Persistence native mobile |
| Analytics | `firebase_analytics` | Événements app + `screen_view` via GoRouter |
| Préférences | `shared_preferences` | Locale UI uniquement |
| Typo | `google_fonts` | Inter **embarqué** (Regular / Italic / Medium / MediumItalic / SemiBold / Bold + OFL). Pas de fetch réseau. |
| Splash / icônes | `flutter_native_splash`, `flutter_launcher_icons` | Asset `assets/branding/app_icon.png` |
| Tests | `flutter_test`, `mocktail`, `fake_cloud_firestore`, `firebase_auth_mocks` | Voir §19 |

**Plateformes générées :** Android, iOS.  
**Min SDK Android :** celui de Flutter (actuellement 24 via le template). Config icône adaptive : `min_sdk_android: 21`.  
**Namespace / applicationId :** `com.fva.songs`.

---

## 6. Architecture logicielle

### 6.1 Clean Architecture par feature

Chaque feature (`songs`, `auth`, et partiellement `add_song` / `favorites` / `moderation`) suit :

```
Presentation  →  Domain (contrats + entités + services purs)  →  Data (implémentations)
```

Règles :

- **Domain** n’importe jamais Flutter Material, Firebase, ni Riverpod (sauf que `Song` est du Dart pur).
- **Presentation** dépend uniquement des **interfaces** Domain (`SongRepository`, `FavoriteRepository`, `SongSubmissionRepository`, `AuthRepository`) et des entités.
- **Data** implémente ces interfaces et isole l’API Firebase dans des datasources.

Conséquence : on peut tester un contrôleur avec `mocktail` sans Firestore, et un datasource avec `FakeFirebaseFirestore` sans réseau.

### 6.2 Couches

```
┌─────────────────────────────────────────────────────────┐
│  Presentation                                           │
│  Screens, widgets, GoRouter, Riverpod controllers       │
│  AddSongController, ModerationController,               │
│  FavoritesController, AdminAuthController, Locale       │
└───────────────────────────┬─────────────────────────────┘
                            │ interfaces Domain
┌───────────────────────────▼─────────────────────────────┐
│  Domain                                                 │
│  Song, SongSubmission, LyricSection                     │
│  SongFilterService, TextNormalizer                      │
│  *Repository (abstract)                                 │
└───────────────────────────┬─────────────────────────────┘
                            │ implémentations
┌───────────────────────────▼─────────────────────────────┐
│  Data                                                   │
│  *RepositoryImpl → *RemoteDataSource → Firebase         │
│  SongModel / SongSubmissionModel (sérialisation)        │
└─────────────────────────────────────────────────────────┘
```

### 6.3 Principes SOLID appliqués

- **S** — `SongFilterService` ne fait que filtrer/scorer ; `SongNumberComparator` ne trie que des numéros ; `TextNormalizer` ne normalise que du texte ; `LocaleController` ne gère que la langue ; les datasources n’exposent pas de règles UI.
- **O** — nouveaux `SearchScope` via le `switch` du scorer (évolution localisée).
- **L** — les `*Impl` sont substituables aux contrats.
- **I** — contrats étroits (`FavoriteRepository` ≠ `SongRepository`).
- **D** — injection via Riverpod (`songRepositoryProvider`, overrides dans les tests).

### 6.4 Bootstrap

`FirebaseBootstrap.initialize()` :

1. `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
2. `FirebaseFirestore.instance.settings` : `persistenceEnabled: true`, `cacheSizeBytes: CACHE_SIZE_UNLIMITED`
3. `_ensureAnonymousUser()` : si `currentUser == null` → `signInAnonymously()`

Le splash natif est conservé pendant cette init (`FlutterNativeSplash.preserve`) puis retiré dans un `finally`.

`SharedPreferences` est injecté via `ProviderScope.overrides` : `sharedPreferencesProvider` throw `UnimplementedError` s’il n’est pas overridé (contrat de démarrage).

---

## 7. Structure du dépôt

```
AGENTS.md                          # normes agents (lire spec.md avant tout changement)
spec.md                            # spec technique (ce document)
README.md
lib/
├── main.dart
├── firebase_options.dart          # généré par FlutterFire
├── l10n/                          # .arb + fichiers générés
├── core/
│   ├── firebase/firebase_bootstrap.dart
│   ├── analytics/                 # AnalyticsClient, observer GoRouter, providers
│   ├── l10n/locale_controller.dart, fallback_localizations.dart
│   ├── responsiveness/            # breakpoints, configs, extensions
│   ├── router/app_router.dart
│   └── theme/app_colors.dart, app_theme.dart
└── features/
    ├── add_song/presentation/     # formulaire + widgets éditeur
    ├── auth/                      # domain / data / presentation complets
    ├── favorites/presentation/    # écran + item
    ├── moderation/presentation/   # file admin
    └── songs/
        ├── domain/entities, repositories, services
        ├── data/datasources, models, repositories
        └── presentation/providers, screens, widgets

test/                              # miroir de lib/ (unitaires)
scripts/                           # import fihirana (Python + JSON)
hosting/                           # landing APK (index.html, analytics-config.js, icône, .bin gitignoré)
firestore.rules
firestore.indexes.json
firebase.json
android/keystore/                  # gitignoré
android/key.properties             # gitignoré
```

Les features `add_song`, `favorites` et `moderation` n’ont **pas** de couche domain propre : elles consomment le domain `songs` / `auth`. C’est volontaire (UI autour du même agrégat).

---

## 8. Modèle métier (domaine)

### 8.1 `SongLanguage`

- `fr`, `mg`
- `fromCode(null | inconnu)` → `fr`

Indépendant de la locale UI.

### 8.2 `SectionType`

- `couplet` — index 1, 2, 3…  
- `refrain`  
- `chorus` — distinct du refrain (usage liturgique / source fihirana)

Un type Firestore inconnu est mappé en `couplet` (migration douce).

### 8.3 `LyricSection`

| Champ | Type | Règle |
| --- | --- | --- |
| `type` | `SectionType` | obligatoire |
| `index` | `int?` | numéro de couplet ; `null` pour refrain/chorus |
| `lines` | `List<String>` | lignes de paroles |
| `isBis` | `bool` | défaut `false` — répétition |

### 8.4 `SongStatus`

- `approved` — visible dans le catalogue public  
- `pending` — non visible (legacy / brouillon éventuel **dans** `songs`)

`fromString` : seul `"pending"` donne `pending`. `null`, `"approved"`, toute autre valeur → `approved` (les anciens documents sans champ `status` restent publics).

Le catalogue public **filtre** `status == approved` côté datasource, en plus du défaut de parsing.

### 8.5 `Song`

| Champ | Rôle |
| --- | --- |
| `id` | Id document Firestore (vide avant insert) |
| `title`, `number`, `author`, `theme`, `key` | Métadonnées |
| `language` | Langue du contenu |
| `firstLine` | Extrait pour les cartes |
| `sections` | Ordre **stocké** (celui saisi / importé) |
| `searchText` | Concaténation normalisée, dénormalisée à l’écriture |
| `status` | Visibilité catalogue |

**`sectionsForDisplay`** (présentation uniquement, ne mute pas `sections`) :

1. S’il n’y a aucun couplet → inchangé.  
2. Extraire toutes les sections `refrain` et `chorus` (ordre relatif conservé).  
3. S’il n’y en a aucune → inchangé.  
4. Réinsérer ce bloc **immédiatement après le premier couplet** du reste.

Usage liturgique : on chante le 1er couplet puis le refrain, même si la source mettait le refrain en fin de fichier.

`copyWith` : tous les champs optionnels, sémantique classique.

### 8.6 `SongSubmission`

| Champ | Rôle |
| --- | --- |
| `id` | Id document `song_submissions` |
| `type` | `create` \| `update` (`fromString` : seul `"update"` → update, sinon create) |
| `status` | `pending` \| `approved` \| `rejected` |
| `createdBy` | `uid` Firebase de l’auteur |
| `payload` | `Song` proposé |
| `targetSongId` | Obligatoire pour `update` |
| `createdAt` | UTC |

`isPending` ⇔ `status == pending`.

### 8.7 Contrats repository

**`SongRepository`**

- `Stream<List<Song>> watchSongs()` — métadonnées du catalogue (sans `sections`)
- `Future<Song?> getById(String id)` — chant complet (paroles incluses)
- `Future<Song> addApprovedSong(Song song)`
- `Future<void> updateSong(Song song)`
- `Future<void> deleteSong(String id)`

**`FavoriteRepository`**

- `Stream<Set<String>> watchFavoriteIds()`
- `addFavorite` / `removeFavorite`
- `toggleFavorite(songId, currentlyFavorite:)` — si déjà favori → remove, sinon add

**`SongSubmissionRepository`**

- `watchPending()`
- `watchMine()` — soumissions de l’utilisateur courant (tous statuts)
- `submitCreate(Song)`
- `submitUpdate({targetSongId, song})`
- `approve(SongSubmission)` / `reject(submissionId)`

**`AuthRepository`**

- `authStateChanges()`, `currentUser`, `isAnonymous`
- `signInAsAdmin({email, password})`
- `signOutToAnonymous()`
- `isCurrentUserAdmin()`, `watchIsAdmin()`

---

## 9. Couche data et schéma Firestore

### 9.1 Collection `songs/{songId}`

Document (id auto Firestore à la création) :

```
title: string
number: string
author: string
theme: string
key: string
language: "fr" | "mg"
firstLine: string
status: "approved" | "pending"
searchText: string          # normalisé
sections: [
  { type: "couplet"|"refrain"|"chorus", index: int|null, lines: [string], isBis: bool }
]
updatedAt: string ISO-8601 UTC
```

Comportement datasource (`SongRemoteDataSource`) :

- `watchSongs` : query Firestore `where status == approved` (index champ unique), tri client `number`. Parse **sans** `sections` (`includeSections: false`). Documents **sans** champ `status` ne matchent pas la query (toutes les écritures actuelles posent `status`). La recherche reste possible via `searchText`. Le SDK mobile **ne projette pas** les champs : le document complet transite encore, mais n’est pas retenu en RAM côté modèle liste.
- `getById` : chant **complet**. Lecture **cache d’abord** (`GetOptions(source: cache)`), puis `get()` réseau / SDK si miss. `null` si absent **ou** non `approved`.
- `addApprovedSong` : force `status: approved`, calcule `searchText`, `collection.add`.
- `updateSong` : `set(merge: true)`, force `approved` + `searchText`.
- `deleteSong` : `doc.delete()` (admin only côté rules).

`addSong` est `@Deprecated` et délègue à `addApprovedSong`.

### 9.2 Collection `song_submissions/{submissionId}`

```
type: "create" | "update"
status: "pending" | "approved" | "rejected"
createdBy: string (uid)
targetSongId: string | null
payload: { ...même forme qu’un document songs... }
createdAt: string ISO-8601 UTC
reviewedAt: string ISO-8601 UTC   # posé au approve/reject (merge)
```

`watchPending` : query Firestore `where status == pending`, tri `createdAt` desc (les `createdAt` nulls en dernier via epoch 0).

`watchMine` : query `where createdBy == uid` ; tri client identique. `StateError` si pas de session.

`submitCreate` / `submitUpdate` : exigent `currentUser.uid`, sinon `StateError`. Recalculent `searchText` du payload.

`approve` :

- `create` → `songs.addApprovedSong(payload)`
- `update` → `songs.updateSong(payload.copyWith(id: targetSongId))` ; `StateError` si `targetSongId` vide
- puis merge `{ status: approved, reviewedAt }`

`reject` : merge `{ status: rejected, reviewedAt }` — **ne touche pas** à `songs`.

### 9.3 Favoris `users/{uid}/favorites/{songId}`

```
createdAt: FieldValue.serverTimestamp()
```

L’id du document **est** l’id du chant. `watchFavoriteIds` = ensemble des ids de documents.  
Sans `currentUser` → `StateError`.

### 9.4 Rôle admin

- `admins/{uid}` : existence = admin. Contenu libre (ex. `{ role: "admin" }`). Écriture console only.
- `config/admins` : `{ emails: [string] }`. Comparaison **lower-case trimmed**. Écriture console only.

### 9.5 Mappers

`SongModel.fromFirestore(id, data, {includeSections = true})` : si `includeSections: false`, `sections` est une liste vide (catalogue).

`SongModel.buildSearchText` concatène titre, numéro, auteur, thème, key, code langue, firstLine, toutes les lignes de sections, puis `TextNormalizer.normalize`.

`toFirestore` régénère `searchText` s’il est vide. Pose toujours `updatedAt` = now UTC.

`SongSubmissionModel.fromFirestore` : `createdAt` string parsée via `DateTime.tryParse` ; valeur invalide → `null`. Payload désérialisé via `SongModel.fromFirestore(targetSongId ?? '', payloadMap)`.

---

## 10. Règles de sécurité Firestore

Fichier : `firestore.rules` (source de vérité **serveur**). L’app ne peut pas les contourner.

```
isSignedIn  ⇔ request.auth != null
isAdmin     ⇔ signed in
            ∧ token.email != null
            ∧ (
                 email == moiseraidjy@gmail.com
              ∨  exists admins/{uid}
              ∨  email ∈ config/admins.emails
              )
```

| Chemin | Read | Write |
| --- | --- | --- |
| `songs/{id}` | authentifié | create : admin **et** `status == approved` ; update/delete : admin |
| `song_submissions/{id}` | admin **ou** auteur (`createdBy == uid`) | create : authentifié, `status == pending`, `createdBy == uid`, type create/update, clés obligatoires ; update : admin et status ∈ approved/rejected/pending ; delete : admin |
| `users/{userId}/favorites/{songId}` | `uid == userId` | idem |
| `config/admins` | authentifié | **interdit** |
| `admins/{uid}` | soi-même ou admin | **interdit** |
| tout le reste | interdit | interdit |

Implications :

- Un fidèle **ne peut pas** créer un chant public, même en forgeant un client.
- Un fidèle **ne peut pas** s’auto-promouvoir admin depuis l’app.
- Un fidèle ne voit pas les soumissions des autres.
- `isAdmin()` côté rules exige un **e-mail** sur le token : un anonyme ne matchera jamais.

---

## 11. Authentification et autorisation

### 11.1 Démarrage

Toujours une session : anonyme si besoin. Permet aux rules `isSignedIn()` de passer.

### 11.2 Login admin

`AdminAuthController.signIn` → `signInWithEmailAndPassword` (email trimé).  
L’écran vérifie ensuite `isCurrentUserAdmin()`. Un compte Auth valide mais hors liste admin est refusé fonctionnellement (la session email existe néanmoins jusqu’à logout).

### 11.3 Résolution du rôle (client)

Ordre dans `_isAdminUser` :

1. Document `admins/{uid}` existe → true  
2. Pas d’e-mail → false  
3. E-mail == fallback → true  
4. Lecture `config/admins.emails` ; en cas d’erreur → fallback email uniquement

Le stream `watchIsAdmin` se recalcule à chaque `authStateChanges`.

### 11.4 Logout admin

`signOut()` puis `signInAnonymously()`. Nouveau `uid` anonyme → **nouveaux favoris vides**.

---

## 12. Flux de modération

```
                    ┌─────────────┐
                    │ Formulaire  │
                    └──────┬──────┘
                           │ AddSongController.save()
                           ▼
                    ┌──────────────┐
                    │ isAdmin() ?  │
                    └─┬──────────┬─┘
                 oui  │          │ non
                      ▼          ▼
              songs.add /    song_submissions
              songs.update   status=pending
              outcome=       type=create|update
              published      outcome=pendingReview
                                 │
                                 ▼
                          Écran /admin
                          (admin only)
                                 │
                    ┌────────────┴────────────┐
                    ▼                         ▼
               approve()                   reject()
        create → addApprovedSong      merge status=rejected
        update → updateSong
        merge status=approved
```

Règles métier du contrôleur :

- `editingSongId` non vide → update, sinon create.
- Admin update n’appelle **jamais** `addApprovedSong`.
- Non-admin n’appelle **jamais** `songs.*`.
- Le `Song` construit pour un save admin a `status: approved` dès la construction ; le datasource le force aussi.

---

## 13. Recherche et filtrage

### 13.1 Normalisation (`TextNormalizer`)

- `toLowerCase().trim()`
- Substitution caractère par caractère d’un dictionnaire d’accents (latin : àâäáãå èêëé … ç ñ ÿ, etc.)
- Caractères hors table : inchangés

### 13.2 `SearchScope`

`all | title | number | author | theme | key | language | favorites`

### 13.3 Algorithme `SongFilterService.filter`

Entrées : liste de chants, query, scope, `Set<String> favoriteIds`.

1. Normaliser la query.  
2. Scope `favorites` **et** query vide → uniquement les favoris, **sans** re-score.  
3. Scope `favorites` **et** query non vide → restreindre d’abord aux favoris, puis scorer.  
4. Query vide (autre scope) → **la même instance** que la liste catalogue (ordre inchangé, pas de copie).  
5. Sinon scorer chaque candidat ; garder score > 0 ; trier par score **décroissant**.

### 13.4 Scoring

Match **numéro exact** (normalisé) → **1000**, quel que soit le scope.

Ensuite selon le scope :

| Scope | Règle |
| --- | --- |
| `title` | startsWith → 800 ; contains → 400 |
| `number` | contains → 700 |
| `author` | startsWith → 600 ; contains → 300 |
| `theme` / `key` | startsWith → 500 ; contains → 250 |
| `language` | code contient la query, **ou** query `francais` et code `fr`, **ou** query `malagasy` et code `mg` → 400 |
| `all` / `favorites` | title startsWith 800 ; number contains 700 ; title contains 600 ; author contains 500 ; theme ou key contains 400 ; `searchText` contains 300 |

Si `searchText` est vide, le service le reconstruit à la volée (même logique que le modèle, sans le code langue).

La recherche **ne interroge pas** Firestore : elle opère sur le snapshot déjà en mémoire.

### 13.5 Debounce

`SearchDebouncer` : timer unique, défaut 200 ms. Un nouvel appel annule le précédent. `dispose` annule le timer (évite setState après unmount).

---

## 14. Navigation et écrans

### 14.1 Routes (`GoRouter`)

| Path | Nom | Écran | Shell |
| --- | --- | --- | --- |
| `/` | `songs` | `SongListScreen` | oui |
| `/favorites` | `favorites` | `FavoritesScreen` | oui |
| `/add` | `add-song` | `AddSongScreen` | oui |
| `/song/:id` | `song-detail` | `SongDetailScreen` | non |
| `/edit/:id` | `edit-song` | `AddSongScreen(editingSong:)` | non |
| `/submissions` | `my-submissions` | `MySubmissionsScreen` | non |
| `/admin/login` | `admin-login` | `AdminLoginScreen` | non |
| `/admin` | `admin-moderation` | `ModerationScreen` | non |

`extra` du détail : `{ title, number }` pour un titre immédiat pendant le chargement. Le corps charge le chant **complet** via `songDetailProvider` (`getById`).

`_EditSongRoute` : même provider (les paroles sont indispensables à l’édition). Si le chant est introuvable → écran « introuvable ».

Listes **Chants** et **Favoris** : `CustomScrollView` + `SliverList` / `SliverGrid` (cartes visibles seulement, `ValueKey(song.id)`). L’écran liste isole AppBar / en-tête / résultats pour limiter les rebuilds. Pas de `ListView`/`GridView` en `shrinkWrap`.

Détail : paroles via `ListView.builder` (`sectionsForDisplay`).

### 14.2 Shell

- **Small / medium** : `NavigationBar` 3 destinations (Chants, Favoris, Ajouter).
- **Large+** (`useNavigationRail`) : `NavigationRail` + divider + contenu.

Pas de garde de route GoRouter sur `/admin` : la protection réelle est Firestore. Un non-admin qui ouvre `/admin` verra une file vide / des erreurs de permission sur le stream.

### 14.3 Widgets clés (songs)

- `SearchBarWidget` — debounce + clear
- `FilterChipsRow` — chips `SearchScope`
- `SongCard` — carte liste
- `LyricsSection` — bloc couplet/refrain/chorus
- `LyricsControllerBar` — zoom police

### 14.4 Formulaire d’ajout

Widgets : `LyricSectionEditor` (une section), `SuccessModal` (titre/corps paramétrables).

L’utilisateur peut ajouter des couplets / un refrain / un chorus. Les couplets sont numérotés localement (`_coupletCount`).

---

## 15. Gestion d’état (Riverpod)

### 15.1 Injection

```
songRemoteDataSourceProvider
songSubmissionRemoteDataSourceProvider  (songs: songRemote…)
favoriteRemoteDataSourceProvider
authRemoteDataSourceProvider

songRepositoryProvider
songSubmissionRepositoryProvider
favoriteRepositoryProvider
authRepositoryProvider
songFilterServiceProvider  → const SongFilterService()
```

### 15.2 Streams / dérivés

| Provider | Type | Source |
| --- | --- | --- |
| `songsCatalogProvider` | `StreamProvider<List<Song>>` | `watchSongs()` (sans paroles) |
| `songByIdProvider(id)` | `Provider<Song?>` | scan du catalogue (métadonnées) |
| `songDetailProvider(id)` | `FutureProvider.autoDispose.family<Song?>` | `getById` ; keepAlive 2 min après la dernière écoute |
| `favoriteIdsProvider` | `StreamProvider<Set<String>>` | `watchFavoriteIds()` |
| `isFavoriteProvider(id)` | `Provider<bool>` | containment |
| `favoriteSongsProvider` | `Provider<List<Song>>` | intersection |
| `searchQueryProvider` | `StateProvider<String>` | `''` |
| `searchScopeProvider` | `StateProvider<SearchScope>` | `all` |
| `filteredSongsProvider` | `Provider<List<Song>>` | `SongFilterService` |
| `pendingSubmissionsProvider` | `StreamProvider<List<SongSubmission>>` | `watchPending()` |
| `mySubmissionsProvider` | `StreamProvider<List<SongSubmission>>` | `watchMine()` |
| `authStateProvider` | `StreamProvider<User?>` | auth |
| `isAdminProvider` | `StreamProvider<bool>` | `watchIsAdmin()` |
| `localeControllerProvider` | `StateNotifierProvider<Locale, LocaleController>` | prefs |

### 15.3 Contrôleurs (pas de state interne)

- `AddSongController` — `isAdmin` injecté comme `bool Function()` (lecture `isAdminProvider` au moment du save, pas au build du provider).
- `ModerationController` — approve / reject
- `FavoritesController` — toggle
- `AdminAuthController` — signIn / signOut

`SongSaveOutcome { published, pendingReview }`.

---

## 16. Hors-ligne (offline-first)

1. Persistence Firestore native Android/iOS, cache illimité.  
2. `watchSongs` émet d’abord le cache puis les mises à jour réseau.  
3. `getById` lit d’abord le cache (documents déjà reçus par le snapshot), donc le détail est immédiat après un catalogue chargé.  
4. L’UI (`catalogAsync.when`) gère loading / error / data. En cas d’erreur réseau après un cache valide, Riverpod peut conserver la dernière data selon le cycle de vie du provider.  
5. Pull-to-refresh force un nouvel abonnement / relecture.  
6. Les **écritures** (favori, soumission) nécessitent typiquement le réseau ; en offline elles restent en file d’attente Firestore jusqu’à reconnexion (comportement SDK), sous réserve des rules une fois synchronisées.  
7. Auth anonyme : le `uid` est persisté par le SDK Auth sur l’appareil → favoris stables tant que l’app n’est pas réinstallée / données effacées.

Pas de mode « pack de chants embarqué dans l’APK » : le premier lancement **avec** réseau est nécessaire pour peupler le cache. Ensuite, lecture offline.

---

## 17. Internationalisation

- Fichiers : `lib/l10n/app_fr.arb`, `app_mg.arb`
- `pubspec.yaml` : `generate: true`, `flutter_localizations`, `intl`
- Locales supportées : `fr` (défaut), `mg`
- Clé prefs : `app_locale_code`
- `FallbackMaterialLocalizationsDelegate` / `FallbackCupertinoLocalizationsDelegate` : `mg` n’existe pas dans Material → widgets framework en FR, chaînes métier en MG.

Le contenu des chants n’est **pas** traduit par l10n : il est stocké dans sa langue (`Song.language`).

---

## 18. Thème, branding et responsive

### 18.1 Couleurs (extrait)

- Primary : `#000666` (indigo profond)
- Secondary / accent : `#FDC003` (jaune)
- Surface : `#FBF9F9`
- On-surface : `#1B1C1C`

Material 3, `ColorScheme` complet dans `AppColors` / `AppTheme.lightTheme`.  
Typo : **Inter** embarqué dans `google_fonts/` (SIL OFL, `OFL.txt`). `GoogleFonts.config.allowRuntimeFetching = false` au démarrage. Styles métier dans `AppTextStyles` (lyrics 22/500, label caps, headlines…).

Pas de thème sombre livré.

### 18.2 Icône et splash

- Source : `assets/branding/app_icon.png`
- Adaptive Android : fond `#E6ECF2`, inset 16
- iOS : `remove_alpha_ios`, fond `#E6ECF2`
- Splash : même couleur + image, y compris Android 12 ; `web: false`

### 18.3 Breakpoints (`Breakpoints`)

| Nom | Largeur max (px) | Grille | Rail | Form columns | maxWidth |
| --- | --- | --- | --- | --- | --- |
| sm | 640 | 1 col, ratio 2.6 | non | 1 | infinity |
| md | 768 | 2, 2.2 | non | 2 | 720 |
| lg | 1024 | 2, 2.4 | oui | 2 | 960 |
| xl | 1280 | 3, 2.1 | oui | 2 | 1100 |
| xxl | > 1280 | 3, 2.0 | oui | 2 | 1280 |

`ResponsiveContent` centre et bride le contenu.

---

## 19. Tests

Emplacement : `test/`, miroir de `lib/`. **129** tests unitaires, `flutter analyze` clean.

| Zone | Outil | Ce qui est couvert |
| --- | --- | --- |
| Entités | pur Dart | enums `fromString`, `copyWith`, `sectionsForDisplay`, `isPending` |
| Services | pur Dart | accents, scopes, ranking, favoris, tri naturel numéros |
| Mappers | pur Dart | round-trip Firestore maps, défauts, `buildSearchText`, `includeSections` |
| Datasources | `FakeFirebaseFirestore`, `MockFirebaseAuth` | filtre approved (query `where`), catalogue sans paroles, cache-first `getById`, CRUD songs, favoris, soumissions, approve/reject, rôle admin |
| Repositories | `mocktail` | délégation + toggle favori |
| Contrôleurs | `mocktail` | admin vs non-admin save, firstLine vide, debounce |
| Providers dérivés | `ProviderContainer` + overrides | intersection favoris, filtre, `songById`, `songDetail` |
| Locale | `SharedPreferences.setMockInitialValues` | persist / toggle / défaut |

Non couvert (volontairement, hors unitaires) : tests de widgets/golden, tests d’intégration Firebase réel, tests iOS/Android natifs.

Commande : `flutter test`

---

## 20. Build, signature et distribution

### 20.1 Versioning

`pubspec.yaml` : `version: 0.1.2+3`  
→ `versionName` 0.1.1, `versionCode` 2 (nécessaire pour réinstaller par-dessus l’APK précédent).

### 20.2 Signature Android

- `android/key.properties` + `android/keystore/fva_songs_release.jks` (**gitignorés**)
- `android/app/build.gradle.kts` : si le fichier existe → `signingConfigs.release` ; sinon fallback **debug** (pour `flutter run --release` local)

Build :

```bash
flutter build apk --release
```

Sortie : `build/app/outputs/flutter-apk/app-release.apk`

### 20.3 Firebase Hosting (contournement Spark)

Le plan Spark **interdit d’uploader** un fichier dont l’extension est `.apk`. Le binaire reste donc stocké en `hosting/fva-songs.bin` (gitignoré).

Chrome Android ignore `Content-Disposition` et l’attribut HTML `download` : il nomme le fichier d’après **l’URL**. D’où le bug « le fidèle télécharge un `.bin` ».

Procédure :

1. Copier l’APK vers `hosting/fva-songs.bin`.
2. URL publique : **`/fva-songs.apk`** — rewrite interne vers `/fva-songs.bin` (le fichier déployé n’est pas un `.apk`, Spark accepte).
3. Redirect 301 `/fva-songs.bin` → `/fva-songs.apk` (anciens liens).
4. Headers sur `/fva-songs.apk` : `Content-Type: application/vnd.android.package-archive`, `Content-Disposition: attachment; filename="fva-songs.apk"`, `Cache-Control: no-cache`.
5. Landing : bouton `href="fva-songs.apk"`.
6. **Analytics landing** : renseigner `hosting/analytics-config.js` avec le Measurement ID GA4 (`G-…`) du flux Web Firebase, puis `firebase deploy --only hosting`.
7. `firebase deploy --only hosting`

**URL :** https://fvasongs-d8055.web.app  
**Console :** https://console.firebase.google.com/project/fvasongs-d8055/overview

iOS : `flutter build ipa` + Apple Developer Program — **non livré**.

### 20.4 Firebase Auth (console)

Providers activés : Anonymous, Email/Password (`firebase.json` section `auth` documentaire + console).

---

## 21. Import du catalogue

Dossier `scripts/` :

- `fihirana_source.txt` — source brute
- `songs_parsed.json` — chants parsés (numéros, y compris `28 bis` / `42 bis` après dédoublonnage)
- `import_fihirana.py` — parsing / import Firestore (outil opérateur, hors runtime mobile)

Le runtime ne lit **pas** ces fichiers : le catalogue vit uniquement dans Firestore.

---

## 22. Contraintes, limites et dettes connues

1. **Favoris liés à l’anonyme** — perte à la réinstallation ; logout admin recrée un uid.  
2. **Pas de garde de route `/admin`** — sécurité réelle = rules.  
3. **Query `status` sans `orderBy`** — `watchSongs` / `watchPending` filtrent côté serveur ; le tri reste client (évite un index composite).  
4. **Pas de projection de champs Firestore (mobile)** — `watchSongs` ignore `sections` au parse, mais le document complet est tout de même téléchargé / mis en cache. Pagination ou collection `songs_meta` = évolution future.  
5. **Login admin remplace la session anonyme** — les favoris de la session anonyme ne sont plus ceux de l’admin (uid différent).  
6. **Clés l10n mortes** — listes de culte / verset du jour.  
7. **Avertissement build** — icônes Cupertino tree-shake (Material seulement). Non bloquant.  
8. **iOS non distribué** — besoin compte développeur Apple.  
9. **E-mail admin bootstrap en dur** dans le client **et** les rules — à garder synchronisé.  
10. **APK ~57 Mo** — poids typique Flutter + fonts ; pas de split-per-abi livré sur la landing (un seul fat APK).  
11. **Pas de CI** dans le dépôt au moment de cette spec.  
12. **Trailer git Cursor** — les commits doivent être réécrits (`commit-tree`) si l’IDE réinjecte `Co-authored-by`.
13. **Analytics sans historique** — GA4 ne remonte pas les usages avant l’activation du SDK / du tag landing.

---

## 23. Évolutions envisagées

Hors spec actuelle, pistes cohérentes avec l’archi :

- Comptes fidèles (email / Google) pour survivre à la réinstall des favoris.
- Listes de culte (clés l10n déjà présentes).
- Pagination du catalogue / collection métadonnées séparée des paroles, pour réduire le trafic réseau.
- Garde GoRouter `redirect` sur `/admin`.
- Play Store / TestFlight.
- Thème sombre.
- Tests widget / golden des écrans critiques.
- Split APKs (armeabi-v7a / arm64) pour réduire le poids du téléchargement.

Toute évolution de schéma Firestore **doit** mettre à jour : ce document, `firestore.rules`, les mappers, et les tests de datasource.

---

## 24. Analytics (GA4)

Mesure d’usage via **Google Analytics 4**, lié au projet Firebase `fvasongs-d8055`. Deux canaux :

| Canal | Mécanisme | Activation |
| --- | --- | --- |
| **App mobile** | Package `firebase_analytics` + abstraction `AnalyticsClient` (`lib/core/analytics/`) | Activer Google Analytics dans la console Firebase (si pas déjà fait) ; rebuild / redéployer l’APK. |
| **Landing Hosting** | gtag GA4 dans `hosting/index.html`, ID dans `hosting/analytics-config.js` | Créer un flux de données **Web** dans Firebase → copier le Measurement ID `G-…` dans `analytics-config.js` → `firebase deploy --only hosting`. |

### 24.1 Architecture app

- **`AnalyticsClient`** — contrat Dart pur ; **`FirebaseAnalyticsClient`** en prod ; **`NoOpAnalyticsClient`** par défaut dans les tests unitaires des contrôleurs.
- **`AnalyticsRouteObserver`** — enregistre un `screen_view` à chaque route GoRouter nommée (`songs`, `favorites`, `song-detail`, etc.).
- Injection Riverpod : `analyticsClientProvider`.

### 24.2 Événements custom (app)

Aucune PII, pas de texte de recherche, pas de titres / paroles de chants.

| Événement | Paramètres | Déclencheur |
| --- | --- | --- |
| `screen_view` | `screenName` (nom de route) | Navigation GoRouter |
| `search` | `scope`, `query_length` | Debounce barre de recherche (query non vide) |
| `search_scope_change` | `scope` | Tap chip filtre |
| `favorite_toggle` | `action` : `add` \| `remove` | Toggle favori |
| `song_save` | `action` : `create` \| `update`, `outcome` : `published` \| `pending_review` | Enregistrement formulaire |
| `moderation_action` | `action` : `approve` \| `reject`, `submission_type` (approve) | Modération admin |
| `locale_change` | `from`, `to` | Bascule FR ↔ MG |
| `admin_auth_sign_in` / `admin_auth_sign_out` | — | Login / logout admin |

### 24.3 Landing

- **`page_view`** automatique si le Measurement ID est renseigné.
- **`apk_download`** — clic sur le bouton de téléchargement Android.

### 24.4 Console et délais

- Rapports : [Firebase Analytics](https://console.firebase.google.com/project/fvasongs-d8055/analytics) (même propriété GA4).
- Agrégats : ~24–48 h ; **DebugView** en quasi temps réel (`adb` / Xcode debug).
- **Pas de rétroactivité** : seules les sessions post-déploiement sont comptées.
