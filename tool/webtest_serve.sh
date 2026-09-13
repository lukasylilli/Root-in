#!/usr/bin/env bash
#
# Liefert `build/web` so aus wie GitHub Pages und startet den Browser-Durchgang
# dagegen (PLAN.md 29.3 / 31.2).
#
# Aufruf:
#   tool/webtest_serve.sh <repository-name> [--gegenprobe]
#
# WARUM EIN EIGENES SKRIPT
# Zwei Arbeitsabläufe brauchen genau diesen Aufbau: `deploy-web.yml` (vor jeder
# Veröffentlichung) und `webtest-gegenprobe.yml` (der absichtlich beschädigte
# Bau). Zwei Kopien liefen auseinander — und die Gegenprobe prüfte irgendwann
# einen anderen Aufbau als den, der wirklich veröffentlicht wird.
set -euo pipefail

cd "$(dirname "$0")/.."

name="${1:?Repository-Name fehlt}"
shift

root="$(mktemp -d)"
# ⚠️ Unter demselben Unterpfad wie GitHub Pages — sonst sucht die Seite ihre
# Dateien eine Ebene zu hoch und zeigt nichts an (PLAN.md Lehre 28).
mkdir -p "$root/$name"
cp -R build/web/. "$root/$name/"

python3 -m http.server 8765 --directory "$root" >/dev/null 2>&1 &
server=$!
trap 'kill "$server" 2>/dev/null || true' EXIT

url="http://localhost:8765/$name/"
for _ in $(seq 1 20); do
  curl -sf -o /dev/null "$url" && break
  sleep 1
done

python3 tool/webtest_ci.py "$@" "$url"
