#!/usr/bin/env bash
#
# Gegenprobe der Server-Zugriffsregeln (PLAN.md Phase 27.4).
#
# Aufruf:
#   tool/rls_check.sh            # liest .env
#   SUPABASE_URL=… SUPABASE_ANON_KEY=… tool/rls_check.sh
#
# WARUM ES DIESES SKRIPT GIBT
# Ein `select` im SQL-Editor beweist NICHTS über die Zugriffsregeln: Er läuft
# mit erhöhten Rechten und umgeht sie. Geprüft werden kann nur von außen, mit
# dem öffentlichen Schlüssel und echten Konten — also genau so, wie ein
# Fremder es täte.
#
# ⚠️ Nach jeder Änderung an `supabase/schema.sql` erneut laufen lassen. Eine
# Regel, die man nicht gegengeprüft hat, ist eine Hoffnung.
#
# Das Skript legt zwei Testkonten an (`@example.com` ist per RFC 2606
# reserviert, es gibt dort niemanden). Sie dürfen stehen bleiben — beim
# nächsten Lauf meldet es sich einfach an — oder in der Supabase-Oberfläche
# unter Authentication → Users gelöscht werden.
set -u

cd "$(dirname "$0")/.."

if [ -f .env ]; then
  # shellcheck disable=SC1091
  set -a; . ./.env; set +a
fi

: "${SUPABASE_URL:?SUPABASE_URL fehlt — .env anlegen (Vorlage: .env.example)}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY fehlt}"

U="$SUPABASE_URL"; K="$SUPABASE_ANON_KEY"
PASS="TestPasswort123"
OK=0; TOTAL=0
BODY=$(mktemp); AUTH=$(mktemp)
trap 'rm -f "$BODY" "$AUTH"' EXIT

check() {
  TOTAL=$((TOTAL+1))
  if [ "$2" = "0" ]; then OK=$((OK+1)); printf "  ✓ %s  %s\n" "$1" "${3:-}"
  else printf "  ✗ %s  %s\n" "$1" "${3:-}"; fi
}

login() {
  local email="$1" tok
  curl -s -X POST "$U/auth/v1/signup" -H "apikey: $K" \
       -H "Content-Type: application/json" \
       -d "{\"email\":\"$email\",\"password\":\"$PASS\"}" > "$AUTH"
  tok=$(python3 -c "import json;print(json.load(open('$AUTH')).get('access_token') or '')" 2>/dev/null)
  if [ -z "$tok" ]; then
    curl -s -X POST "$U/auth/v1/token?grant_type=password" -H "apikey: $K" \
         -H "Content-Type: application/json" \
         -d "{\"email\":\"$email\",\"password\":\"$PASS\"}" > "$AUTH"
    tok=$(python3 -c "import json;print(json.load(open('$AUTH')).get('access_token') or '')" 2>/dev/null)
  fi
  echo "$tok"
}

uid_of() {
  python3 -c "import json;d=json.load(open('$AUTH'));print((d.get('user') or {}).get('id',''))" 2>/dev/null
}

req() { # method path token [body] [prefer]
  local m="$1" p="$2" t="$3" b="${4:-}" pref="${5:-}"
  local args=(-s -o "$BODY" -w "%{http_code}" -X "$m" "$U$p"
              -H "apikey: $K" -H "Authorization: Bearer $t"
              -H "Content-Type: application/json")
  [ -n "$pref" ] && args+=(-H "Prefer: $pref")
  [ -n "$b" ] && args+=(-d "$b")
  curl "${args[@]}"
}

foreign_rows() { # eigene_id -> Anzahl FREMDER Zeilen
  python3 -c "
import json
try: d = json.load(open('$BODY'))
except Exception: print('?'); raise SystemExit
print(sum(1 for r in d if r.get('user_id') != '$1') if isinstance(d, list) else '?')"
}

echo "Prüfe die Zugriffsregeln von außen — mit dem öffentlichen Schlüssel."
echo "$U"
echo

# --- Schicht 1: ohne Anmeldung darf gar nichts gehen -------------------------
C=$(req GET "/rest/v1/profiles?select=*" "$K")
[ "$C" -ge 400 ] && check "OHNE Anmeldung kein Zugriff auf profiles" 0 "HTTP $C" \
                 || check "OHNE Anmeldung kein Zugriff auf profiles" 1 "HTTP $C — OFFEN!"
C=$(req GET "/rest/v1/backups?select=*" "$K")
[ "$C" -ge 400 ] && check "OHNE Anmeldung kein Zugriff auf backups" 0 "HTTP $C" \
                 || check "OHNE Anmeldung kein Zugriff auf backups" 1 "HTTP $C — OFFEN!"

# --- Zwei Konten -------------------------------------------------------------
TA=$(login "rootin-test-a@example.com"); IA=$(uid_of)
[ -n "$TA" ] && check "Konto A anlegen/anmelden" 0 || check "Konto A anlegen/anmelden" 1 "$(head -c 140 "$AUTH")"
[ -n "$TA" ] && check "„Confirm email\" ist AUS (sofort anmeldbar)" 0 \
             || check "„Confirm email\" ist AUS (sofort anmeldbar)" 1 "sonst gibt es kein Token"

TB=$(login "rootin-test-b@example.com"); IB=$(uid_of)
[ -n "$TB" ] && check "Konto B anlegen/anmelden" 0 || check "Konto B anlegen/anmelden" 1 "$(head -c 140 "$AUTH")"

if [ -z "$TA" ] || [ -z "$TB" ]; then echo; echo "Abbruch: zwei Konten nötig."; exit 1; fi

C=$(req POST /rest/v1/profiles "$TA" "{\"user_id\":\"$IA\",\"username\":\"testkonto-a\"}" "resolution=merge-duplicates")
[ "$C" -lt 400 ] && check "A schreibt seine EIGENE Profilzeile" 0 "HTTP $C" || check "A schreibt seine eigene Profilzeile" 1 "HTTP $C $(head -c 120 "$BODY")"
C=$(req POST /rest/v1/profiles "$TB" "{\"user_id\":\"$IB\",\"username\":\"testkonto-b\"}" "resolution=merge-duplicates")
[ "$C" -lt 400 ] && check "B schreibt seine EIGENE Profilzeile" 0 "HTTP $C" || check "B schreibt seine eigene Profilzeile" 1 "HTTP $C $(head -c 120 "$BODY")"

# --- Schicht 2: sieht wirklich jeder nur sich selbst? ------------------------
req GET "/rest/v1/profiles?select=user_id,username" "$TA" >/dev/null
F=$(foreign_rows "$IA")
[ "$F" = "0" ] && check "A sieht AUSSCHLIESSLICH die eigene Zeile" 0 "0 fremde" || check "A sieht ausschliesslich die eigene Zeile" 1 "$F FREMDE!"

req GET "/rest/v1/profiles?select=*&user_id=eq.$IB" "$TA" >/dev/null
N=$(python3 -c "import json;d=json.load(open('$BODY'));print(len(d) if isinstance(d,list) else '?')" 2>/dev/null)
[ "$N" = "0" ] && check "A findet B NICHT, auch gezielt gefragt" 0 "leer" || check "A findet B nicht, auch gezielt gefragt" 1 "$N Zeile(n)!"

C=$(req POST /rest/v1/backups "$TA" "{\"user_id\":\"$IB\",\"payload\":{\"x\":1},\"schema_version\":1}")
[ "$C" -ge 400 ] && check "A kann KEINE Sicherung auf B's Kennung schreiben" 0 "HTTP $C" || check "A kann keine Sicherung auf B's Kennung schreiben" 1 "HTTP $C — DURCHGELASSEN!"

C=$(req POST /rest/v1/backups "$TA" "{\"user_id\":\"$IA\",\"payload\":{\"x\":1},\"schema_version\":1}" "resolution=merge-duplicates")
[ "$C" -lt 400 ] && check "A darf seine EIGENE Sicherung schreiben" 0 "HTTP $C" || check "A darf seine eigene Sicherung schreiben" 1 "HTTP $C $(head -c 120 "$BODY")"

req GET "/rest/v1/backups?select=user_id" "$TB" >/dev/null
F=$(foreign_rows "$IB")
[ "$F" = "0" ] && check "B sieht A's Sicherung NICHT" 0 "0 fremde" || check "B sieht A's Sicherung nicht" 1 "$F FREMDE!"

# --- Eindeutigkeit des Benutzernamens ---------------------------------------
C=$(req PATCH "/rest/v1/profiles?user_id=eq.$IB" "$TB" "{\"username\":\"testkonto-a\"}")
[ "$C" -ge 400 ] && check "B kann A's Benutzernamen NICHT übernehmen" 0 "HTTP $C" || check "B kann A's Benutzernamen nicht übernehmen" 1 "HTTP $C — DURCHGELASSEN!"

echo
echo "$OK/$TOTAL bestanden."
[ "$OK" = "$TOTAL" ]
