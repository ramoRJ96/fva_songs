#!/usr/bin/env bash
set -euo pipefail

: "${VERSION_NAME:?VERSION_NAME is required}"
: "${VERSION_CODE:?VERSION_CODE is required}"

APK_SRC="build/app/outputs/flutter-apk/app-release.apk"
APK_DST="hosting/fva-songs.bin"

if [[ ! -f "$APK_SRC" ]]; then
  echo "Missing release APK at $APK_SRC" >&2
  exit 1
fi

cp "$APK_SRC" "$APK_DST"

APK_SIZE_MB="$(du -m "$APK_DST" | cut -f1)"

sed -i "s/Version [0-9.]* ·/Version ${VERSION_NAME} ·/" hosting/index.html
sed -i "s/· ~[0-9]* Mo ·/· ~${APK_SIZE_MB} Mo ·/" hosting/index.html

cat > hosting/app-version.json <<EOF
{
  "versionName": "${VERSION_NAME}",
  "versionCode": ${VERSION_CODE},
  "downloadUrl": "https://fvasongs-d8055.web.app/fva-songs.apk"
}
EOF

echo "Prepared hosting release ${VERSION_NAME} (${VERSION_CODE}), APK ~${APK_SIZE_MB} Mo"
