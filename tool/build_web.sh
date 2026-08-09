#!/usr/bin/env bash
#
# Baut die Web-Fassung von Root-in (PLAN.md Phase 26.3/26.4/26.6).
#
# **Die eine Stelle**, an der die Bau-Schalter stehen — die Automatik
# (.github/workflows/deploy-web.yml) ruft dieses Skript auf, statt die Flags
# ein zweites Mal zu führen. Sonst liefe der Bau des Nutzers irgendwann
# anders als der veröffentlichte.
#
# Aufruf:
#   tool/build_web.sh                 # lokal testen (base-href "/")
#   tool/build_web.sh /Root-in/       # wie auf GitHub Pages
#
set -euo pipefail

cd "$(dirname "$0")/.."

BASE_HREF="${1:-/}"
FLUTTER="${FLUTTER:-flutter}"

# Baunummer: in der Automatik die Lauf-Nummer, lokal 0 (PLAN.md Phase 26.6).
BUILD_NUMBER="${GITHUB_RUN_NUMBER:-0}"

# Versionsname aus pubspec.yaml lesen, statt ihn hier ein zweites Mal zu
# pflegen — eine Quelle für alle Plattformen, genau wie beim Android-Bau.
# Aus `version: 1.0.0+1` wird `1.0.0`.
APP_VERSION="$(awk -F'[:+ ]+' '/^version:/{print $2; exit}' pubspec.yaml)"

if [ -z "${APP_VERSION}" ]; then
  echo "FEHLER: version nicht aus pubspec.yaml lesbar." >&2
  exit 1
fi

# Die Web-Datenbank-Dateien sind Bauartefakte und liegen nicht im Repository.
./tool/fetch_web_db_assets.sh

echo "Baue Web-Fassung ${APP_VERSION}+${BUILD_NUMBER} (base-href ${BASE_HREF}) …"

"${FLUTTER}" build web \
  --release \
  --base-href "${BASE_HREF}" \
  --build-name "${APP_VERSION}" \
  --build-number "${BUILD_NUMBER}" \
  `# Dieselben Werte zusätzlich als --dart-define, damit die App sie ZEIGEN` \
  `# kann (core/constants/app_config.dart). --build-name/--build-number` \
  `# allein landen im Web nur in version.json, nicht im Dart-Code.` \
  --dart-define=APP_VERSION="${APP_VERSION}" \
  --dart-define=BUILD_NUMBER="${BUILD_NUMBER}" \
  `# Ohne Source-Maps gibt es im Browser keinen lesbaren Dart-Code. Sie` \
  `# sind im Release ohnehin aus, hier steht es ausdrücklich da — der` \
  `# Auftrag verlangt es (PLAN.md Phase 26.4).` \
  --no-source-maps \
  `# Höchste dart2js-Optimierungsstufe. Nebeneffekt: kürzere, unkenntliche` \
  `# Namen. KEINE Verschlüsselung — die Grenze steht in PLAN.md 26.4.` \
  -O4 \
  `# Erzeugt keinen Code zur Laufzeit (kein eval). Erlaubt eine strenge` \
  `# Content-Security-Policy und nimmt eine ganze Angriffsklasse weg.` \
  --csp \
  --no-wasm-dry-run

echo "Fertig: build/web"
