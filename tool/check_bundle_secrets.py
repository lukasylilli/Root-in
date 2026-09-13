#!/usr/bin/env python3
"""Kein geheimer Supabase-Schlüssel im ausgelieferten Bundle (PLAN.md 27.10 / 31.5).

Aufruf (macht `deploy-web.yml` nach dem Bau selbst):
    python3 tool/check_bundle_secrets.py build/web
    python3 tool/check_bundle_secrets.py build/web --expect-anon

Warum es dieses Skript gibt
---------------------------
PLAN.md 27.10 nennt das gefährlichste Risiko der Konto-Phase: Gerät der
`service_role`-Schlüssel in die App, hat **jeder** vollständigen Zugriff auf
die Datenbank — er umgeht jede Zugriffsregel, und das Bundle ist öffentlich
lesbar (Lehre 26). Als Gegenmaßnahme stand dort „im Bundle nach ihm suchen".
Getan hat es niemand: Eine Regel, die nur im Dokument steht, hält niemanden
auf (Lehre 35). Jetzt sucht die Automatik bei jedem Bau.

Was verboten ist, was erlaubt
-----------------------------
- ⛔ **`service_role`** — ein JWT, dessen Nutzlast `"role": "service_role"` trägt.
- ⛔ **`sb_secret_…`** — die neue Form des geheimen Schlüssels.
- ✅ **`anon`** (JWT mit `"role": "anon"`) bzw. **`sb_publishable_…`** — steht
  absichtlich im Bundle; ohne ihn gäbe es keine Anmeldung.

⚠️ `--expect-anon`: der Zeuge (Lehre 32)
----------------------------------------
Ein Suchlauf, der nichts findet, ist grün — auch dann, wenn er an der falschen
Stelle sucht. Ist ein Supabase-Secret hinterlegt, MUSS der erlaubte Schlüssel
im Bundle auftauchen. Findet das Skript ihn nicht, ist es blind, und sein
„kein geheimer Schlüssel" wäre wertlos. Mit `--expect-anon` ist das ein
Fehlschlag.

Die Schlüssel werden nie ausgegeben — nur, WO etwas gefunden wurde.
"""
import base64
import json
import os
import pathlib
import re
import sys

JWT = re.compile(rb"eyJ[A-Za-z0-9_-]{8,}\.eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}")
SECRET = re.compile(rb"sb_secret_[A-Za-z0-9_-]{8,}")
PUBLISHABLE = re.compile(rb"sb_publishable_[A-Za-z0-9_-]{8,}")

# Größere Dateien sind Bilder oder WebAssembly — dort landet kein Schlüssel,
# den `--dart-define` hineinschreibt.
MAX_BYTES = 50 * 1024 * 1024


def role_of(token):
    """Die Rolle aus der Nutzlast eines JWT, ohne die Signatur zu prüfen."""
    try:
        payload = token.split(b".")[1]
        payload += b"=" * (-len(payload) % 4)
        return json.loads(base64.urlsafe_b64decode(payload)).get("role")
    except Exception:
        return None


def scan(root):
    """Gibt (verbotene Funde, Zahl der erlaubten Schlüssel) zurück."""
    forbidden, allowed = [], 0
    for path in sorted(pathlib.Path(root).rglob("*")):
        if not path.is_file() or path.stat().st_size > MAX_BYTES:
            continue
        data = path.read_bytes()
        where = str(path.relative_to(root))
        for token in JWT.findall(data):
            role = role_of(token)
            if role == "service_role":
                forbidden.append(f"{where}: JWT mit role=service_role")
            elif role == "anon":
                allowed += 1
        forbidden += [f"{where}: sb_secret_…" for _ in SECRET.findall(data)]
        allowed += len(PUBLISHABLE.findall(data))
    return forbidden, allowed


def melden(stufe, text):
    """Als Arbeitsablauf-Anmerkung — die ist ohne Anmeldung lesbar."""
    if os.environ.get("GITHUB_ACTIONS"):
        print(f"::{stufe}::{text}", flush=True)
    else:
        print(f"[{stufe}] {text}", flush=True)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        print("Aufruf: check_bundle_secrets.py <ordner> [--expect-anon]")
        return 2
    root = args[0]
    expect_anon = "--expect-anon" in sys.argv

    forbidden, allowed = scan(root)
    if forbidden:
        melden("error", "GEHEIMER SCHLÜSSEL IM BUNDLE — nicht veröffentlichen, "
                        "Schlüssel in Supabase sofort erneuern: "
                        + " · ".join(forbidden))
        return 1
    if expect_anon and allowed == 0:
        melden("error", "Kein erlaubter anon-/publishable-Schlüssel im Bundle "
                        "gefunden, obwohl einer erwartet wird — die Suche ist "
                        "blind, ihr „nichts gefunden\" beweist nichts.")
        return 1
    melden("notice", f"Kein geheimer Schlüssel im Bundle "
                     f"({allowed} erlaubte(r) öffentliche(r) Schlüssel gefunden).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
