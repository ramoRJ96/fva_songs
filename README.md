# FVA Songs

A cross-platform Flutter app for browsing, searching, and contributing worship songs and hymns. Built offline-first with Firebase, it lets every user browse the full song catalog and submit new songs or edits, while an admin reviews and approves every change before it becomes public.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Running the App](#running-the-app)
- [Testing](#testing)
- [Localization](#localization)
- [Moderation Workflow](#moderation-workflow)
- [Distribution](#distribution)
- [Firestore Data Model](#firestore-data-model)

## Features

- **Song catalog** — Browse all approved songs, offline-first thanks to Firestore's local cache, with pull-to-refresh to force a sync.
- **Fast search & filters** — Instant, in-memory search with a scoped filter (title, number, author, theme, key, language, or favorites only), accent- and case-insensitive.
- **Song detail view** — Adjustable font size, and automatic lyrics reordering so the refrain/chorus always appears right after the first verse, regardless of how it was originally entered.
- **Favorites** — Mark songs as favorites and access them from a dedicated tab.
- **Community contributions** — Any signed-in user can submit a new song or propose an edit to an existing one.
- **Admin moderation** — An administrator signs in with email/password and reviews every pending submission (create or update) before it is published. Regular users' submissions never go live automatically.
- **Bilingual UI** — Fully localized in French and Malagasy, switchable from the app bar.
- **Responsive layout** — Adapts from mobile to tablet/desktop (bottom navigation bar vs. navigation rail, grid columns, paddings).
- **Custom branding** — Dedicated app icon and native splash screen for Android and iOS.

## Tech Stack

| Layer          | Choice                                                      |
| --------------- | ------------------------------------------------------------ |
| Framework       | [Flutter](https://flutter.dev) (Dart)                        |
| State management| [flutter_riverpod](https://riverpod.dev)                     |
| Navigation      | [go_router](https://pub.dev/packages/go_router)               |
| Backend         | [Firebase](https://firebase.google.com) (Auth, Cloud Firestore, Hosting) |
| Auth            | Anonymous auth for regular users, email/password for admins  |
| Local storage   | Firestore offline persistence + `shared_preferences` (locale) |
| Fonts           | [google_fonts](https://pub.dev/packages/google_fonts)         |
| Testing         | `flutter_test`, [mocktail](https://pub.dev/packages/mocktail), [fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore), [firebase_auth_mocks](https://pub.dev/packages/firebase_auth_mocks) |

## Architecture

The codebase follows **Clean Architecture**, split into three layers per feature:

- **Domain** — Framework-agnostic entities (`Song`, `SongSubmission`), repository contracts (interfaces), and pure business services (`SongFilterService`, `TextNormalizer`). No Firebase or Flutter dependency here.
- **Data** — Repository implementations and Firestore/Auth datasources. Firestore documents are mapped to/from domain entities via dedicated models (`SongModel`, `SongSubmissionModel`).
- **Presentation** — Riverpod providers/controllers and Flutter screens/widgets. Controllers (`AddSongController`, `ModerationController`, `FavoritesController`, `AdminAuthController`) hold the UI-facing business logic and depend only on domain repository interfaces, which keeps them easy to unit test with mocks.

This separation means the domain and most of the data layer can be tested without a real Firebase project (see [Testing](#testing)).

## Project Structure

```
lib/
├── core/                     # Cross-cutting concerns
│   ├── firebase/             # Firebase bootstrap (init, offline persistence)
│   ├── l10n/                 # Locale controller & fallback localizations
│   ├── responsiveness/       # Breakpoints, layout configs, extensions
│   ├── router/               # GoRouter configuration
│   └── theme/                # Colors & text styles
├── features/
│   ├── add_song/             # Song creation/edit form
│   ├── auth/                 # Admin authentication (domain/data/presentation)
│   ├── favorites/             # Favorites screen & widgets
│   ├── moderation/            # Admin moderation queue screen
│   └── songs/                 # Song catalog, search, detail (domain/data/presentation)
├── l10n/                     # Generated localizations (from .arb files)
└── main.dart                 # App entry point

test/                         # Mirrors lib/ structure — see Testing section
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.10.1`, see `pubspec.yaml`)
- A [Firebase](https://console.firebase.google.com) project with **Firestore**, **Authentication** (Anonymous + Email/Password providers enabled), and (optionally) **Hosting**
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`) if you plan to deploy Firestore rules or Hosting
- Xcode (for iOS) and/or Android Studio (for Android) with a configured simulator/emulator

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd fva_songs
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Connect your Firebase project**

   This repo already ships `lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist` for the original project. To point the app at your own Firebase project instead, run:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This regenerates `lib/firebase_options.dart` and the platform config files for your project.

4. **Enable Authentication providers**

   In the Firebase console, enable both **Anonymous** and **Email/Password** sign-in methods.

5. **Deploy Firestore security rules**

   ```bash
   firebase deploy --only firestore:rules
   ```

6. **Grant yourself admin rights**

   An account is treated as admin if any of these is true (see `AuthRemoteDataSource`):
   - its email matches the fallback admin email hardcoded in the datasource, **or**
   - a document exists at `admins/{uid}` in Firestore, **or**
   - its email is listed in `config/admins.emails`.

   The simplest way for a new project is to create your admin user in Firebase Authentication, then add a document at `admins/{uid}` (any content) in Firestore.

7. **Generate app icons & splash screen** (only needed if you change `assets/branding/app_icon.png`)

   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

### Running the App

```bash
flutter run
```

Localizations are generated automatically on build (`generate: true` in `pubspec.yaml`). If you edit the `.arb` files under `lib/l10n/` and don't see the changes, run:

```bash
flutter gen-l10n
```

## Testing

The `test/` folder mirrors the `lib/` structure and covers the domain, data, and presentation layers with **119 unit tests** and no dependency on a real Firebase project:

- **Domain** — entities (`Song`, `SongSubmission`) and pure services (`SongFilterService`, `TextNormalizer`).
- **Data / mappers** — Firestore (de)serialization round-trips (`SongModel`, `SongSubmissionModel`).
- **Datasources** — Firestore/Auth logic exercised against in-memory fakes ([fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore), [firebase_auth_mocks](https://pub.dev/packages/firebase_auth_mocks)), so no network or emulator is required.
- **Repositories** — delegation to datasources, verified with [mocktail](https://pub.dev/packages/mocktail).
- **Presentation** — controllers (`AddSongController`, `ModerationController`, `FavoritesController`, `AdminAuthController`, `SearchDebouncer`) and derived Riverpod providers.

Run the full suite:

```bash
flutter test
```

Run a single file or directory:

```bash
flutter test test/features/songs/domain
```

## Localization

The UI is available in **French (`fr`, default)** and **Malagasy (`mg`)**. Strings live in `lib/l10n/app_fr.arb` and `lib/l10n/app_mg.arb`; the language toggle in the app bar persists the user's choice via `shared_preferences` (`LocaleController`).

## Moderation Workflow

1. Any authenticated user (anonymous by default) can create a new song or edit an existing one from the **Add** tab.
2. If the current user **is not** an admin, the change is stored as a `SongSubmission` with `status: pending` in the `song_submissions` collection — the public catalog is untouched.
3. An admin signs in with email/password (via the shield icon in the app bar) and opens the **Moderation** screen, which lists all pending submissions.
4. Approving a submission publishes it: a `create` submission is inserted into `songs` with `status: approved`; an `update` submission overwrites the target song. Rejecting simply marks the submission as `rejected`.
5. If the current user **is** an admin, saving a song publishes it directly — no review step.

This logic lives in `AddSongController` and `ModerationController` (`lib/features/songs/presentation/providers/songs_providers.dart`) and is enforced server-side by `firestore.rules`.

## Distribution

- **Android** — a signed release APK can be built with `flutter build apk --release` (signing config in `android/app/build.gradle.kts`, backed by a local, git-ignored `android/key.properties` + keystore). The `hosting/` folder contains a small landing page used to distribute the APK directly via Firebase Hosting (deploy with `firebase deploy --only hosting`).
- **iOS** — building and distributing to TestFlight/App Store requires an active Apple Developer Program membership (`flutter build ipa`).

## Firestore Data Model

| Collection                          | Purpose                                                            |
| ------------------------------------ | -------------------------------------------------------------------- |
| `songs/{songId}`                     | Approved, publicly visible songs (title, number, author, lyrics…). |
| `song_submissions/{submissionId}`    | Pending/approved/rejected create or update proposals awaiting review. |
| `users/{uid}/favorites/{songId}`      | Per-user favorite song ids.                                          |
| `admins/{uid}` / `config/admins`      | Admin role assignment, checked by `firestore.rules` and `AuthRemoteDataSource`. |
