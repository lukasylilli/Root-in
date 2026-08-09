#!/usr/bin/env bash
#
# Holt die beiden Dateien, die Drift im Browser braucht, nach `web/`:
#   sqlite3.wasm     — SQLite als WebAssembly
#   drift_worker.js  — Drifts Web-Worker
#
# Warum ein Skript und kein Commit (siehe PLAN.md Phase 26.1/26.2):
# Beides sind **Bauartefakte** und gehören laut Auftrag nicht ins Repository.
# Sie stehen deshalb in `web/.gitignore`; dieses Skript ist die eine Stelle,
# die sie beschafft — lokal wie in der Automatik.
#
# Warum nicht `dart run drift_dev make-worker`:
# Der Befehl bricht mit drift 2.34.2 / drift_dev 2.34.0 ab
# ("The getter 'allSchemaEntities' isn't defined"). Die Veröffentlichung von
# drift liefert dieselben Dateien fertig gebaut mit.
#
# ⚠️ Die Version MUSS zur drift-Version aus pubspec.lock passen. Ein Worker
# aus einer anderen Fassung spricht unter Umständen ein anderes Protokoll mit
# der Datenbank — das fällt erst im Browser auf, nicht beim Bauen.
set -euo pipefail

cd "$(dirname "$0")/.."

# Version aus pubspec.lock lesen, statt sie hier ein zweites Mal zu pflegen.
DRIFT_VERSION="$(awk '/^  drift:/{f=1} f && /^    version:/{gsub(/[" ]/,"",$2); print $2; exit}' pubspec.lock)"

if [ -z "${DRIFT_VERSION}" ]; then
  echo "FEHLER: drift-Version nicht aus pubspec.lock lesbar." >&2
  exit 1
fi

BASE="https://github.com/simolus3/drift/releases/download/drift-${DRIFT_VERSION}"
echo "Hole Web-Datenbank-Dateien für drift ${DRIFT_VERSION} …"

for file in sqlite3.wasm drift_worker.js; do
  # --fail lässt curl bei 404 mit Fehler abbrechen, statt eine HTML-Seite
  # als "sqlite3.wasm" abzulegen — die App startete dann im Browser nicht
  # und der Grund wäre schwer zu finden.
  curl --fail --silent --location --output "web/${file}" "${BASE}/${file}"
  echo "  web/${file} ✓"
done

echo "Fertig."
