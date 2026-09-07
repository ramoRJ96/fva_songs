#!/usr/bin/env bash
# Cloud Agent install script for FVA Songs (Flutter).
# Idempotent: installs the pinned Flutter SDK + Android SDK, then refreshes
# project dependencies and generated localizations. Safe to run repeatedly.
set -euo pipefail

# Flutter version is pinned by .fvmrc / CI (see AGENTS.md, README.md).
FLUTTER_VERSION="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc 2>/dev/null || true)"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.1}"
FLUTTER_DIR="$HOME/flutter"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/android-sdk}"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-13114758_latest.zip"

echo "==> Flutter $FLUTTER_VERSION"
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  git clone -b "$FLUTTER_VERSION" --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"
# Expose flutter/dart on the default PATH for every future shell (no profile edits).
sudo ln -sf "$FLUTTER_DIR/bin/flutter" /usr/local/bin/flutter
sudo ln -sf "$FLUTTER_DIR/bin/dart" /usr/local/bin/dart
flutter config --no-analytics >/dev/null 2>&1 || true

echo "==> Android SDK"
export ANDROID_SDK_ROOT ANDROID_HOME="$ANDROID_SDK_ROOT"
CMDLINE_BIN="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
if [ ! -x "$CMDLINE_BIN/sdkmanager" ]; then
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/cmdtools.zip" "https://dl.google.com/android/repository/$CMDLINE_TOOLS_ZIP"
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
  unzip -q "$tmp/cmdtools.zip" -d "$ANDROID_SDK_ROOT/cmdline-tools"
  rm -rf "$ANDROID_SDK_ROOT/cmdline-tools/latest"
  mv "$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools" "$ANDROID_SDK_ROOT/cmdline-tools/latest"
  rm -rf "$tmp"
fi
export PATH="$CMDLINE_BIN:$ANDROID_SDK_ROOT/platform-tools:$PATH"
yes | sdkmanager --licenses >/dev/null 2>&1 || true
# android-35 = Flutter 3.47.1 default compileSdk; android-36/build-tools pinned by android/settings.gradle.kts.
# cmake pre-installed so gradle native builds don't need an interactive license prompt.
sdkmanager \
  "platform-tools" \
  "platforms;android-35" \
  "platforms;android-36" \
  "build-tools;36.0.0" \
  "cmake;3.22.1" >/dev/null
flutter config --android-sdk "$ANDROID_SDK_ROOT" >/dev/null 2>&1 || true

echo "==> Project dependencies"
flutter precache --android >/dev/null
flutter pub get
flutter gen-l10n

echo "==> Install complete"
dart --version
