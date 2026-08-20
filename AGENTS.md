# AGENTS.md — FVA Songs

Instructions for coding agents working in this repository.

## Spec first (mandatory)

1. **Read `spec.md` before any code change.** It is the technical source of truth (architecture, domain, Firestore schema, security rules, flows, limits).
2. **If the change alters behaviour, architecture, schema, rules, screens, or conventions, update `spec.md` in the same change** (version/date of the document, relevant section, and the “limits / future” sections if needed).
3. Do not invent product rules that contradict `spec.md`. If the code and the spec disagree, fix the gap and record it in `spec.md`.
4. Do not duplicate `spec.md` here. This file only states *how* to work.

Also see `README.md` for human setup (clone, Firebase, run, deploy).

## Product in one sentence

Offline-first bilingual hymnbook (FR/MG). Anyone can read, search, favourite, and **submit** songs. Only an **admin** publishes to the public catalogue.

## Architecture

Clean Architecture per feature (`domain` → `data` → `presentation`):

- **Domain**: pure Dart. No Flutter Material, no Firebase, no Riverpod.
- **Presentation**: screens/widgets/controllers depend on **repository interfaces**, never on datasources.
- **Data**: `*RepositoryImpl` + `*RemoteDataSource` + `*Model` mappers.

Do not put Firestore or Auth calls in widgets or domain entities.

## Hard product rules

- Public catalogue = `songs` with `status == approved` only. Regular users never write `songs`.
- User create/update → `song_submissions` (`pending`). Admin save → direct publish.
- Display lyrics with `song.sectionsForDisplay` (refrain/chorus after the first verse). Do not reorder stored `sections` for display.
- Anonymous auth at startup; admin = email/password + role (`admins/{uid}`, `config/admins.emails`, or bootstrap email in datasource **and** `firestore.rules` — keep them in sync).
- Search is in-memory (`SongFilterService` + `searchText`). Do not query Firestore for each keystroke.
- UI copy goes through l10n (`app_fr.arb` / `app_mg.arb` + `flutter gen-l10n`). Do not hardcode user-facing strings.

## Commands

```bash
flutter pub get
flutter gen-l10n
flutter test
flutter analyze
flutter build apk --release
```

## Git and secrets

- Commit messages in English, imperative, matching existing history.
- Do not include `Co-authored-by: Cursor` (or any Cursor trailer) in commits.
- Never commit `android/key.properties`, `android/keystore/`, `hosting/*.apk`, `hosting/*.bin`, or Firebase tokens.
- Do not reformat unrelated `lib/` files.

## Tests

- New domain/data/controller logic needs unit tests next to the existing `test/` mirror.
- Prefer `mocktail` for repositories/controllers, `fake_cloud_firestore` + `firebase_auth_mocks` for datasources.
- Keep `flutter test` green.

## Distribution

Android APK is stored as `hosting/fva-songs.bin` (Spark blocks uploading `.apk`) but **served at `/fva-songs.apk`** via Hosting rewrite (Android names the file from the URL). After a release build: copy the APK to `hosting/fva-songs.bin`, bump `pubspec.yaml` versionCode if users must overwrite the previous install, update the landing version string, deploy `--only hosting`, and reflect the version in `spec.md`. The CD workflow (`.github/workflows/cd.yml`, spec §20.6) does the same from GitHub Actions; it needs repository secrets and a manual `workflow_dispatch` (or a GitHub Release). Never put keystore passwords or `FIREBASE_TOKEN` in git.

## Language

Respond to the user in **French**. Keep code, comments, commit messages, and `README.md` as they are (code/comments FR where existing, README EN).
