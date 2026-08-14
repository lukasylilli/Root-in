#!/usr/bin/env python3
"""Echter Browser-Durchgang der veröffentlichten Web-Fassung (PLAN.md 26.7).

Aufruf:
    python3 tool/webtest.py                       # gegen die veröffentlichte Seite
    python3 tool/webtest.py http://localhost:8765/  # gegen einen lokalen Bau

Voraussetzung (einmalig, verlangt das Mac-Passwort):
    safaridriver --enable

Warum dieses Skript existiert
-----------------------------
Ein grüner Testlauf beweist die Logik, nicht den Browser. Drift geht im Web
einen völlig anderen Weg (WebAssembly + OPFS/IndexedDB), und ob das trägt,
zeigt sich erst beim echten Aufruf. Lehre 8 im Plan gilt hier genauso.

Zwei Kniffe, ohne die es nicht geht
-----------------------------------
1. Flutter zeichnet auf eine Canvas — es gibt keine anklickbaren DOM-Knoten.
   Ein Klick auf Flutters Barrierefreiheits-Schalter baut den Semantik-Baum
   als echte Elemente auf; danach lässt sich nach Text suchen. Geklickt wird
   trotzdem mit einem **echten Zeiger-Ereignis** auf die Mitte des Elements:
   ein `.click()` trifft sonst den äußeren Container.
2. safaridriver gibt jeder Sitzung ein **leeres Profil**. Ein Persistenz-Test
   über zwei Sitzungen hinweg misst deshalb nichts. Der Vergleich muss
   innerhalb einer Sitzung stattfinden: Zustand herstellen → neu laden →
   prüfen.
"""
import base64
import json
import subprocess
import sys
import time
import urllib.request

PORT = 4444
BASE = f"http://localhost:{PORT}"
URL = sys.argv[1] if len(sys.argv) > 1 else "https://lukasylilli.github.io/Root-in/"


def call(method, path, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(
        BASE + path, data=data, method=method,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=120) as response:
        return json.loads(response.read())


def main():
    driver = subprocess.Popen(
        ["safaridriver", "-p", str(PORT)],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    time.sleep(3)
    session = None
    failures = []

    try:
        try:
            session = call("POST", "/session", {
                "capabilities": {"alwaysMatch": {"browserName": "safari"}},
            })["value"]["sessionId"]
        except Exception as error:
            print("Sitzung nicht möglich. Zuerst einmalig ausführen:")
            print("    safaridriver --enable")
            print(f"({error})")
            return 2

        # Telefon-Format: so sieht es der Nutzer, für den die Fassung gebaut ist.
        call("POST", f"/session/{session}/window/rect",
             {"x": 0, "y": 0, "width": 430, "height": 930})

        def js(script):
            return call("POST", f"/session/{session}/execute/sync",
                        {"script": script, "args": []})["value"]

        def boot():
            for _ in range(60):
                time.sleep(1)
                if js("return !!document.querySelector('flutter-view');"):
                    time.sleep(7)  # Datenbank + erster echter Frame
                    js("var p=document.querySelector('flt-semantics-placeholder');"
                       "if(p) p.click();")
                    time.sleep(3)
                    return True
            return False

        def leaves():
            """Blätter des Semantik-Baums samt Mittelpunkt."""
            return js("""
              var out = [];
              document.querySelectorAll('flt-semantics').forEach(function(e){
                if (e.querySelector('flt-semantics')) return;
                var t = (e.getAttribute('aria-label') || e.textContent || '').trim();
                var r = e.getBoundingClientRect();
                if (t && r.width > 0 && r.height > 0)
                  out.push({t: t, x: Math.round(r.x + r.width / 2),
                                  y: Math.round(r.y + r.height / 2)});
              });
              return out;
            """)

        def tap(label, exact=True, wait=3):
            for node in leaves():
                if (node["t"] == label) if exact else (label in node["t"]):
                    call("POST", f"/session/{session}/actions", {"actions": [{
                        "type": "pointer", "id": "finger",
                        "parameters": {"pointerType": "touch"},
                        "actions": [
                            {"type": "pointerMove", "duration": 0,
                             "x": node["x"], "y": node["y"]},
                            {"type": "pointerDown", "button": 0},
                            {"type": "pause", "duration": 60},
                            {"type": "pointerUp", "button": 0},
                        ]}]})
                    time.sleep(wait)
                    return True
            return False

        def check(name, condition, detail=""):
            print(f"  {'✓' if condition else '✗'} {name}{'  ' + detail if detail else ''}")
            if not condition:
                failures.append(name)

        print(f"Prüfe: {URL}\n")

        call("POST", f"/session/{session}/url", {"url": URL})
        check("App startet", boot())

        texts = [n["t"] for n in leaves()]
        check("Erststart-Erklärung erscheint", any("Root-in" in t for t in texts))
        check("Erklärung überspringbar", tap("رد کردن") or tap("Überspringen") or tap("Skip"))
        time.sleep(4)

        # Der Hinweis aus Phase 26.8 — er gehört genau hierhin.
        hint = [n["t"] for n in leaves()]
        check("Speicher-Hinweis der Web-Fassung erscheint",
              any(("صفحهٔ اصلی" in t) or ("Home-Bildschirm" in t) or ("home screen" in t)
                  for t in hint))
        tap("متوجه شدم") or tap("Verstanden") or tap("Got it")
        time.sleep(3)

        storage = js("return Object.keys(localStorage).join(',');")
        check("Einstellungen landen im Browser-Speicher",
              "onboarding_seen" in storage, storage)

        databases = js("""
          if (!indexedDB.databases) return 'unbekannt';
          return indexedDB.databases().then(function(d){
            return d.map(function(x){ return x.name; }).join(',');
          });
        """)
        check("Datenbank im Browser angelegt", "root_in_db" in str(databases), str(databases))

        # Der eigentliche Beweis: überlebt der Bestand einen vollständigen Neustart?
        call("POST", f"/session/{session}/url", {"url": URL})
        boot()
        after = [n["t"] for n in leaves()]
        check("Nach dem Neuladen KEINE Erklärung mehr (Zustand erhalten)",
              not any("خوش آمدید" in t or "Willkommen" in t for t in after))
        check("Datenbank nach dem Neuladen noch da",
              "root_in_db" in str(js("""
                if (!indexedDB.databases) return 'unbekannt';
                return indexedDB.databases().then(function(d){
                  return d.map(function(x){ return x.name; }).join(',');
                });""")))

        print()
        if failures:
            print(f"FEHLGESCHLAGEN: {len(failures)} — {', '.join(failures)}")
            return 1
        print("Alles bestanden.")
        return 0

    finally:
        if session:
            try:
                call("DELETE", f"/session/{session}")
            except Exception:
                pass
        driver.terminate()


if __name__ == "__main__":
    sys.exit(main())
