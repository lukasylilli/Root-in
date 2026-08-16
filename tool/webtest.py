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

Drei Kniffe, ohne die es nicht geht
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
3. Der Semantik-Baum enthält auch Knoten **außerhalb** des Sichtfelds. Ihre
   Koordinaten sind echt, aber unerreichbar — ein Tipp darauf landet
   irgendwo, im Zweifel auf der Navigationsleiste. Wer weiter unten in einer
   Liste etwas antippen will, muss vorher scrollen (siehe `scroll_to`) —
   und zwar mit einem **Rad**-Ereignis: Ein Finger-Wisch bewegt eine Flutter-
   Liste im Desktop-Browser nicht, ohne dass irgendetwas fehlschlägt.

⚠️ Was dieser Durchgang abdeckt, ist der Umfang der Prüfung — nicht mehr
--------------------------------------------------------------------------
Die erste Fassung (Phase 26.7) prüfte Start, Erststart-Erklärung,
Speicher-Hinweis und Datenerhalt und bestand alle acht Prüfungen. Sie hatte
dabei **keinen einzigen der vier Reiter angetippt** — und drei der vier
Hauptseiten waren zu diesem Zeitpunkt unbenutzbar (PLAN.md 26.10). Der
Nutzer hat sie gefunden, nicht dieses Skript.

Seit Phase 26.11 geht der Durchgang deshalb durch **alle vier Reiter** und
öffnet eine Anleitungs-Seite. Wer hier eine Seite hinzufügt, fügt sie auch
hier hinzu — sonst wächst die Lücke, die genau einmal zu teuer war
(PLAN.md Lehre 31).
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
            """Wartet, bis die App wirklich steht — nicht nur eine feste Zeit.

            ⚠️ Eine feste Wartezeit hat sich gerächt: Gegen `localhost` reicht
            sie, gegen die veröffentlichte Seite über eine langsamere Leitung
            nicht — dann tippt der Durchgang auf eine Erklärung, die noch da
            ist, und JEDE folgende Prüfung misst etwas anderes als gedacht.
            Gewartet wird deshalb auf das erste Ergebnis, nicht auf die Uhr.
            """
            for _ in range(60):
                time.sleep(1)
                if not js("return !!document.querySelector('flutter-view');"):
                    continue
                time.sleep(5)  # Datenbank + erster echter Frame
                for _ in range(20):
                    js("var p=document.querySelector('flt-semantics-placeholder');"
                       "if(p) p.click();")
                    time.sleep(1)
                    if leaves():
                        time.sleep(2)  # der Rest des Aufbaus
                        return True
                return False
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

        def tap_any(*labels, exact=True, wait=3):
            """Erste Beschriftung, die es gibt — die Oberfläche kann in jeder
            der drei Sprachen laufen (sie folgt der Gerätesprache)."""
            for label in labels:
                if tap(label, exact=exact, wait=wait):
                    return True
            return False

        def scroll_down(distance=400):
            """Scrollt die Liste ein Stück nach unten — mit einem **Rad**-
            Ereignis, nicht mit einem Wisch.

            ⚠️ Ein Wisch (Finger-Drag) bewirkt hier **nichts**. Flutter
            erlaubt das Ziehen einer Liste nur auf Geräten mit Berührung; im
            Desktop-Browser bleibt die Liste stehen, ohne dass etwas
            fehlschlägt. Zwei aufeinanderfolgende Wische ließen die
            Koordinaten hier unverändert — der Fehler sieht aus wie „das
            Element gibt es nicht", ist aber „die Seite hat sich nie bewegt".
            """
            call("POST", f"/session/{session}/actions", {"actions": [{
                "type": "wheel", "id": "wheel",
                "actions": [{"type": "scroll", "x": 215, "y": 400,
                             "deltaX": 0, "deltaY": distance,
                             "duration": 200}],
            }]})
            time.sleep(1.5)

        def scroll_to(*labels, tries=6):
            """Scrollt, bis eine der Beschriftungen WIRKLICH im Sichtfeld liegt.

            ⚠️ Nicht „bis es sie im Baum gibt": Der Semantik-Baum führt auch
            Knoten unterhalb des Bildschirmrands, mit echten, aber
            unerreichbaren Koordinaten. Ein Tipp darauf landet auf der
            Navigationsleiste — genau so ist der erste Versuch dieses
            Durchgangs ins Leere gelaufen und hat dabei sogar „bestanden"
            gemeldet.
            """
            height = js("return window.innerHeight;")
            nav_bar = height - 90  # darunter liegt die Bottom-Navigation
            for _ in range(tries):
                for node in leaves():
                    if any(label in node["t"] for label in labels):
                        if 80 < node["y"] < nav_bar:
                            return True
                scroll_down()
            return False

        def check(name, condition, detail=""):
            print(f"  {'✓' if condition else '✗'} {name}{'  ' + detail if detail else ''}")
            if not condition:
                failures.append(name)

        def shows(*labels):
            """Steht eine dieser Beschriftungen gerade auf dem Bildschirm?"""
            texts = [n["t"] for n in leaves()]
            return any(any(label in t for label in labels) for t in texts)

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

        # ------------------------------------------------------------------
        # Ab hier: die Seiten, die der erste Durchgang nie besucht hat
        # (PLAN.md 26.10/26.11). Jede dieser Prüfungen wäre am Stand vom
        # 2026-08-14 rot gewesen.
        # ------------------------------------------------------------------
        print()

        # HEUTE. Geprüft wird der Kopfbereich mit Punkten und Erledigt-Zähler.
        # Er hängt am Datum — und genau daran ist die Seite gescheitert: ohne
        # Datum blieb hier ein Ladekreis ohne Ende stehen.
        check("Reiter „Heute“ öffnet sich", tap_any("امروز", "Heute", "Today", wait=5))
        check("Heute zeigt seinen Tagesring mit Punkten und Erledigt-Zähler",
              shows("امتیاز", "Punkte", "Points") and
              shows("انجام‌شده", "Erledigt", "Done"))

        # ANSICHT. Die vier Reiter allein beweisen nichts — sie standen auch
        # da, als die Seite kaputt war. Die Überschrift „Diese Woche" kommt
        # erst, wenn das Datum steht.
        check("Reiter „Ansicht“ öffnet sich", tap_any("نما", "View", wait=5))
        check("Ansicht zeigt den Zeitraum „Diese Woche“",
              shows("این هفته", "Diese Woche", "This week"))

        # ANLEITUNG. Die Rubrik steht weit unten in den Einstellungen —
        # ohne Scrollen tippt man auf die Navigationsleiste.
        check("Reiter „Einstellungen“ öffnet sich",
              tap_any("تنظیمات", "Einstellungen", "Settings", wait=5))
        planning = ("برنامه‌ریزی یادگیری", "Lernplanung", "Study planning")
        check("Rubrik „Root-in Anleitung“ ist erreichbar", scroll_to(*planning))
        tap_any(*planning, exact=False, wait=8)
        time.sleep(4)

        # ⚠️ „Getippt" ist nicht „geöffnet", und die Adresszeile hilft hier
        # NICHT: Die Anleitung wird mit `context.push` geöffnet, und die
        # Adresse bleibt dabei auf `#/settings` stehen. Der Beweis ist eine
        # UND-Verknüpfung: Das Thema steht auf dem Schirm **und** die
        # Bottom-Navigation ist verschwunden (die Anleitung liegt außerhalb
        # der Shell). Einzeln taugt keines von beiden — den Titel zeigt auch
        # die Einstellungen-Liste, und ohne Navigation ist auch die
        # Erststart-Erklärung.
        on_guide = shows(*planning) and not shows("خانه", "Home")
        check("Anleitungs-Seite ist wirklich offen", on_guide)

        # Der Fehlerzustand wird am KNOPF „Erneut versuchen" erkannt, nicht
        # an der Überschrift „Kein Internet".
        #
        # ⚠️ Und das ist kein Geschmacksurteil: Reine Text-Widgets tauchen im
        # Semantik-Baum unzuverlässig auf (von einer ganzen Seite Anleitung
        # kommen dort nur rund 190 Zeichen an), Knöpfe dagegen immer — sie
        # tragen `role="button"`. Eine Prüfung auf die Überschrift meldete
        # deshalb GRÜN, während der Fehlerzustand deutlich sichtbar auf dem
        # Bildschirm stand. Was der Baum nicht führt, darf man nicht abfragen.
        #
        # ⚠️ Die Prüfung hängt außerdem an `on_guide`: Sie sucht eine
        # ABWESENHEIT, und etwas Abwesendes findet sich überall — auch auf
        # der Erststart-Erklärung. Genau so hat dieser Block sich schon
        # einmal selbst betrogen.
        check("Anleitung bietet keinen „Erneut versuchen“-Knopf an",
              on_guide and not shows("تلاش دوباره", "Erneut versuchen", "Try again"))
        # ⚠️ Den Markdown-Text über den Semantik-Baum zu messen, funktioniert
        # NICHT: Von einer vollen Seite Text kommen dort nur rund 190 Zeichen
        # an (Kopfkarte und Tabellenzellen) — die Absätze fehlen. Eine
        # Prüfung „genug Text auf dem Bildschirm" wäre also rot, obwohl die
        # Seite gefüllt ist.
        #
        # Der bessere Beweis liegt ohnehin daneben: Ein geglückter Abruf legt
        # den Text unter `repo_content_<pfad>` im Browser-Speicher ab. Ist
        # der Eintrag da, hat der Netzzugriff im Browser funktioniert — und
        # genau das war kaputt.
        cached = js("""
          var out = [];
          Object.keys(localStorage).forEach(function(k){
            if (k.indexOf('repo_content_') >= 0)
              out.push(k.split('repo_content_')[1] + ':' +
                       localStorage.getItem(k).length);
          });
          return out.join(', ');
        """)
        check("Anleitungs-Text wurde geladen und abgelegt",
              "lernplanung" in str(cached).lower(), str(cached))

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
