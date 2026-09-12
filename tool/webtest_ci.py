#!/usr/bin/env python3
"""Browser-Durchgang **in der Automatik** (PLAN.md 29.3).

Aufruf:
    python3 tool/webtest_ci.py http://localhost:8765/Root-in/

Warum es dieses Skript gibt
---------------------------
`tool/webtest.py` fährt echtes Safari über safaridriver und braucht deshalb
einen Mac. Seit PLAN.md Phase 29 gibt es keinen mehr. Damit stand die
Hauptplattform ohne jede Browser-Prüfung da: **Keiner der 209 Tests öffnet
einen Browser** — sie laufen alle auf der Dart-VM. Genau diese Lücke hat in
Phase 26 drei kaputte Hauptseiten durchgelassen (Lehre 31), und sie war nach
Phase 29 wieder offen (Lehre 39).

Dieses Skript schließt sie mit dem, was auf `ubuntu-latest` ohnehin liegt:
Chrome und ChromeDriver. Gesprochen wird dasselbe WebDriver-Protokoll wie in
`webtest.py`, über schlichtes HTTP mit `urllib` — **keine zusätzliche
Abhängigkeit**, kein Selenium, kein Playwright.

⚠️ Was hier NICHT geprüft wird, und warum
------------------------------------------
Der Durchgang meldet sich **nicht an**. Ein Oberflächen-Test, der Konten
anlegt, hinterlässt bei jedem Lauf Datenmüll auf dem Server. Dass die
Anmeldung trägt, beweist `.github/workflows/rls-check.yml` mit echten Konten
von außen. **Zwei Werkzeuge, zwei Zuständigkeiten.**

⚠️ Die teuer bezahlten Regeln aus `webtest.py` gelten hier genauso
-------------------------------------------------------------------
1. **Die Zeichenfläche liegt im Schatten-DOM** von `flt-glass-pane`.
   `document.querySelectorAll('canvas')` liefert bei Flutter **immer 0** —
   auch bei einer tadellos laufenden App (Lehre 36).
2. **Zustände an KNÖPFEN ablesen, nie an Überschriften.** Reine Text-Widgets
   stehen unzuverlässig im Semantik-Baum, Knöpfe immer (Lehre 32/35).
3. **Auf Zustände warten, nicht auf die Uhr.** Eine feste Wartezeit reicht
   mal und mal nicht (Lehre 36).
4. **Scheitert der Start, wird abgebrochen.** Sonst meldet ein leerer
   Semantik-Baum eine Ursache als ein Dutzend Fehler (Lehre 36).
5. **Prüfungen auf eine Abwesenheit brauchen einen Zeugen**, dass überhaupt
   etwas da ist — sonst werden sie grün, wenn gar nichts geladen hat.
"""
import json
import os
import subprocess
import sys
import time
import urllib.request

PORT = 9515
BASE = f"http://localhost:{PORT}"
URL = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8765/Root-in/"


def call(method, path, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(
        BASE + path, data=data, method=method,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=120) as response:
        return json.loads(response.read())


def chromedriver_pfad():
    """Wo ChromeDriver liegt — auf GitHub-Runnern über `CHROMEWEBDRIVER`."""
    ordner = os.environ.get("CHROMEWEBDRIVER")
    if ordner:
        kandidat = os.path.join(ordner, "chromedriver")
        if os.path.exists(kandidat):
            return kandidat
    return "chromedriver"


def main():
    driver = subprocess.Popen(
        [chromedriver_pfad(), f"--port={PORT}"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    time.sleep(3)
    session = None
    failures = []

    try:
        try:
            session = call("POST", "/session", {"capabilities": {"alwaysMatch": {
                "browserName": "chrome",
                "goog:chromeOptions": {"args": [
                    "--headless=new",
                    "--no-sandbox",
                    "--disable-dev-shm-usage",
                    "--disable-gpu",
                    # Telefon-Format: so sieht es der Nutzer, für den die
                    # Fassung gebaut ist.
                    "--window-size=430,930",
                ]},
            }}})["value"]["sessionId"]
        except Exception as error:
            print(f"ChromeDriver nicht erreichbar: {error}")
            return 2

        def js(script):
            return call("POST", f"/session/{session}/execute/sync",
                        {"script": script, "args": []})["value"]

        def painted():
            """Zeichenflächen im **Schatten-DOM**. 0 = nichts gemalt.

            ⚠️ Im hellen DOM findet man sie nie — siehe Kopf der Datei.
            """
            return js("""
              var g = document.querySelector('flt-glass-pane');
              if (!g || !g.shadowRoot) return 0;
              return g.shadowRoot.querySelectorAll('canvas').length;
            """) or 0

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

        def boot():
            for _ in range(90):
                time.sleep(1)
                if not js("return !!document.querySelector('flutter-view');"):
                    continue
                for _ in range(45):
                    if painted():
                        break
                    time.sleep(1)
                else:
                    return False
                # Flutters Barrierefreiheits-Schalter baut den Semantik-Baum
                # als echte Elemente auf — erst danach lässt sich etwas lesen.
                for _ in range(25):
                    js("var p=document.querySelector('flt-semantics-placeholder');"
                       "if(p) p.click();")
                    time.sleep(1)
                    if leaves():
                        time.sleep(2)
                        return True
                return False
            return False

        def diagnosis():
            if not js("return !!document.querySelector('flutter-view');"):
                return ("Die Seite hat Flutter gar nicht geladen — stimmt die "
                        "Adresse, und wurde `build/web` wirklich ausgeliefert?")
            if not painted():
                return ("Flutter ist geladen, hat aber nichts gezeichnet. "
                        "DAS ist der Fall, für den dieser Durchgang gebaut "
                        "wurde: Die App startet nicht, und ohne ihn ginge sie "
                        "so online.")
            return ("Gezeichnet ist, aber der Semantik-Baum bleibt leer — der "
                    "Klick auf 'flt-semantics-placeholder' hat nicht gezogen.")

        def wait_until(condition, seconds=15):
            for _ in range(seconds * 2):
                if condition():
                    return True
                time.sleep(0.5)
            return False

        def shows(*labels):
            """⚠️ Nur nach KNÖPFEN und Listeneinträgen fragen, nie nach
            Überschriften — reine Texte stehen unzuverlässig im Semantik-Baum
            (Lehre 32/35)."""
            texts = [n["t"] for n in leaves()]
            return any(any(label in t for label in labels) for t in texts)

        def tap(label, exact=True, wait=2):
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

        def tap_any(*labels, wait=2):
            """Die Oberfläche folgt der Gerätesprache — im CI meist Englisch,
            lokal oft Deutsch oder Persisch. Deshalb jede Beschriftung in
            allen drei Sprachen anbieten."""
            return any(tap(label, wait=wait) for label in labels)

        def check(name, condition, detail=""):
            print(f"  {'✓' if condition else '✗'} {name}{'  ' + detail if detail else ''}")
            if not condition:
                failures.append(name)

        print(f"Prüfe: {URL}\n")
        call("POST", f"/session/{session}/url", {"url": URL})

        # ⚠️ Kommt die App nicht hoch, wird ABGEBROCHEN — die folgenden
        # Prüfungen würden sonst dieselbe eine Ursache vielfach melden.
        if not boot():
            check("App startet", False)
            print(f"\nABBRUCH: {diagnosis()}")
            return 1
        check("App startet und zeichnet", True, f"canvas={painted()}")

        # Erststart-Erklärung wegklicken. Der Knopf trägt je nach Sprache
        # einen anderen Text; „Root-in" steht in allen dreien.
        check("Erststart-Erklärung erscheint", shows("Root-in"))
        tap_any("رد کردن", "Überspringen", "Skip", wait=4)

        storage = js("return Object.keys(localStorage).join(',');")
        check("Einstellungen landen im Browser-Speicher",
              "onboarding_seen" in storage, storage)

        databases = js("""
          if (!indexedDB.databases) return 'unbekannt';
          return indexedDB.databases().then(function(d){
            return d.map(function(x){ return x.name; }).join(',');
          });
        """)
        check("Datenbank im Browser angelegt",
              "root_in_db" in str(databases), str(databases))

        # Die vier Reiter. ⚠️ Dass sie DA sind, beweist nichts — sie standen
        # auch da, als drei der vier Seiten leer blieben (PLAN.md 26.10).
        # Geprüft wird deshalb ein Inhalt, der erst erscheint, wenn die Seite
        # wirklich baut.
        check("Reiter „Heute“ öffnet sich",
              tap_any("امروز", "Heute", "Today", wait=4))
        check("Heute zeigt Punkte und Erledigt-Zähler",
              wait_until(lambda: shows("امتیاز", "Punkte", "Points")))

        check("Reiter „Ansicht“ öffnet sich",
              tap_any("نما", "Ansicht", "View", wait=4))
        check("Ansicht zeigt einen Zeitraum",
              wait_until(lambda: shows("این هفته", "Diese Woche", "This week")))

        check("Reiter „Einstellungen“ öffnet sich",
              tap_any("تنظیمات", "Einstellungen", "Settings", wait=4))
        check("Einstellungen zeigen ihre Einträge",
              wait_until(lambda: shows("اشتراک", "teilen", "Share")))

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
