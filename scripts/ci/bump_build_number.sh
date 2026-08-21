#!/usr/bin/env bash
set -euo pipefail

VERSION_LINE="$(grep '^version:' pubspec.yaml)"
if [[ ! "$VERSION_LINE" =~ version:\ ([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+) ]]; then
  echo "Invalid pubspec version format (expected name+code): $VERSION_LINE" >&2
  exit 1
fi

VERSION_NAME="${BASH_REMATCH[1]}"
VERSION_CODE="${BASH_REMATCH[2]}"
NEW_CODE=$((VERSION_CODE + 1))

sed -i "s/^version: .*/version: ${VERSION_NAME}+${NEW_CODE}/" pubspec.yaml

echo "Bumped to ${VERSION_NAME}+${NEW_CODE}"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "version_name=${VERSION_NAME}" >> "$GITHUB_OUTPUT"
  echo "version_code=${NEW_CODE}" >> "$GITHUB_OUTPUT"
fi
