#!/usr/bin/env python3
"""Browser-Durchgang **in der Automatik** (PLAN.md 29.3, erweitert in 31.2).

Aufruf (macht `tool/webtest_serve.sh` in der Automatik selbst):
    python3 tool/webtest_ci.py http://localhost:8765/Root-in/
    python3 tool/webtest_ci.py --gegenprobe http://localhost:8765/Root-in/

Warum es dieses Skript gibt
---------------------------
`tool/webtest.py` fährt echtes Safari über safaridriver und braucht deshalb
einen Mac. Seit PLAN.md Phase 29 gibt es keinen mehr. Damit stand die
Hauptplattform ohne jede Browser-Prüfung da: **Keiner der Tests öffnet einen
Browser** — sie laufen alle auf der Dart-VM. Genau diese Lücke hat in
Phase 26 drei kaputte Hauptseiten durchgelassen (Lehre 31), und sie war nach
Phase 29 wieder offen (Lehre 39).

Dieses Skript schließt sie mit dem, was auf `ubuntu-latest` ohnehin liegt:
Chrome und ChromeDriver. Gesprochen wird dasselbe WebDriver-Protokoll wie in
`webtest.py`, über schlichtes HTTP mit `urllib` — **keine zusätzliche
Abhängigkeit**, kein Selenium, kein Playwright.

Was geprüft wird
----------------
Start, Erststart-Erklärung, Speicher-Hinweis, Browser-Speicher, Datenbank,
die drei Reiter **mit Inhalt** (29.3) — und seit 31.2 wieder alles, was
`webtest.py` zusätzlich konnte: eine Anleitungs-Seite samt geladenem Text,
der Zustand nach dem Neuladen, die Rubrik „Konto & Cloud" und die
veröffentlichte `privacy.html`.

⚠️ Die Gegenprobe (`--gegenprobe`, PLAN.md 31.2, Lehre 32)
----------------------------------------------------------
Ein Oberflächen-Test, der nie rot war, prüft nichts. Mit `--gegenprobe`
sperrt der Durchgang `raw.githubusercontent.com` im Browser und erwartet eine
Konto-Rubrik; `.github/workflows/webtest-gegenprobe.yml` baut dazu ohne
Supabase-Schlüssel und löscht `privacy.html`. **Bestanden ist die Gegenprobe
nur, wenn GENAU die Prüfungen aus `GEGENPROBE_ROT` rot sind** — bleibt eine
davon grün, prüft sie nichts; wird eine andere rot, hat die Beschädigung
mehr getroffen als gedacht. Beides meldet sie als Fehlschlag.

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
6. **Gescrollt wird mit einem RAD-Ereignis.** Ein Wisch bewegt eine
   Flutter-Liste im Desktop-Browser nicht, ohne dass etwas fehlschlägt.
"""
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

PORT = 9515
BASE = f"http://localhost:{PORT}"

_ADDRESSES = [a for a in sys.argv[1:] if not a.startswith("--")]
URL = _ADDRESSES[0] if _ADDRESSES else "http://localhost:8765/Root-in/"
if not URL.endswith("/"):
    URL += "/"

GEGENPROBE = "--gegenprobe" in sys.argv

# Ist die App MIT Supabase-Schlüsseln gebaut, MUSS die Rubrik „Konto & Cloud"
# erscheinen. ⚠️ Ohne diesen Schalter hielte der Durchgang eine fehlende
# Rubrik für „ohne Schlüssel gebaut" — und eine Änderung, die sie versehentlich
# versteckt, ginge grün durch. Die Automatik setzt ihn, wenn das Secret da ist.
EXPECT_CLOUD = GEGENPROBE or os.environ.get("WEBTEST_EXPECT_CLOUD") == "1"

# Namen der Prüfungen, die die Gegenprobe rot sehen muss. Als Konstanten, weil
# jeder Name an zwei Stellen gebraucht wird — ein Tippfehler an einer davon
# ließe die Gegenprobe still ins Leere laufen.
GUIDE_CACHED = "Anleitungs-Text wurde geladen und abgelegt"
GUIDE_NO_RETRY = "Anleitung bietet keinen „Erneut versuchen“-Knopf an"
CLOUD_SIGN_IN = "Rubrik „Konto & Cloud“ bietet Anmelden an"
PRIVACY_REACHABLE = "privacy.html ist erreichbar"
PRIVACY_LANGUAGES = "privacy.html enthält beide Sprachfassungen"
PRIVACY_NO_NOTE = "privacy.html enthält die INTERNE NOTIZ nicht"

GEGENPROBE_ROT = {
    GUIDE_CACHED,
    GUIDE_NO_RETRY,
    CLOUD_SIGN_IN,
    PRIVACY_REACHABLE,
    PRIVACY_LANGUAGES,
    PRIVACY_NO_NOTE,
}


def call(method, path, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(
        BASE + path, data=data, method=method,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=120) as response:
        return json.loads(response.read())


def fetch(url):
    """Holt eine Datei ohne Browser. Gibt (Inhalt, Status) zurück."""
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            return response.read().decode("utf-8", "replace"), response.status
    except urllib.error.HTTPError as error:
        return "", error.code
    except Exception as error:
        return "", str(error)


IN_CI = bool(os.environ.get("GITHUB_ACTIONS"))


def melden(stufe, text):
    """Gibt eine Meldung so aus, dass die Automatik sie als **Anmerkung** zeigt.

    ⚠️ Ohne das ist ein gescheiterter Lauf von außen stumm: Das Protokoll
    eines Laufs braucht eine Anmeldung (HTTP 403), die Anmerkungen dagegen
    sind bei einem öffentlichen Repository frei lesbar. Genau daran hing der
    erste Fehlschlag dieses Durchgangs — er meldete „exit code 1" und sonst
    nichts, und niemand konnte sagen, woran es lag.
    """
    if IN_CI:
        # Zeilenumbrüche müssen in Arbeitsablauf-Befehlen maskiert werden,
        # sonst bricht die Meldung nach der ersten Zeile ab.
        print(f"::{stufe}::{text}".replace("\n", "%0A"), flush=True)
    else:
        print(f"  [{stufe}] {text}", flush=True)


def chromedriver_pfad():
    """Wo ChromeDriver liegt — auf GitHub-Runnern über `CHROMEWEBDRIVER`."""
    ordner = os.environ.get("CHROMEWEBDRIVER")
    if ordner:
        kandidat = os.path.join(ordner, "chromedriver")
        if os.path.exists(kandidat):
            return kandidat
    return "chromedriver"


def urteil(failures, bestanden):
    """Normaler Lauf: grün, wenn nichts rot ist. Gegenprobe: grün, wenn GENAU
    die erwarteten Prüfungen rot sind."""
    if not GEGENPROBE:
        if failures:
            print(f"FEHLGESCHLAGEN: {len(failures)} — {', '.join(failures)}")
            melden("error", f"Browser-Durchgang: {len(failures)} von "
                            f"{len(failures) + bestanden} Prüfungen rot — "
                            f"{', '.join(failures)}")
            return 1
        print("Alles bestanden.")
        melden("notice", f"Browser-Durchgang: alle {bestanden} Prüfungen grün.")
        return 0

    rot = set(failures)
    if rot == GEGENPROBE_ROT:
        print(f"GEGENPROBE BESTANDEN: genau die {len(rot)} erwarteten Prüfungen "
              f"sind rot, die übrigen {bestanden} grün.")
        melden("notice", f"Gegenprobe bestanden: {len(rot)} erwartete Prüfungen "
                         f"rot, {bestanden} grün.")
        return 0
    blieben_gruen = sorted(GEGENPROBE_ROT - rot)
    unerwartet_rot = sorted(rot - GEGENPROBE_ROT)
    teile = []
    if blieben_gruen:
        teile.append("GRÜN trotz Beschädigung (prüfen also nichts): "
                     + ", ".join(blieben_gruen))
    if unerwartet_rot:
        teile.append("unerwartet rot: " + ", ".join(unerwartet_rot))
    print("GEGENPROBE GESCHEITERT — " + " · ".join(teile))
    melden("error", "Gegenprobe gescheitert — " + " · ".join(teile))
    return 1


def main():
    driver = subprocess.Popen(
        [chromedriver_pfad(), f"--port={PORT}"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    time.sleep(3)
    session = None
    failures = []

    chrome_args = [
        "--headless=new",
        "--no-sandbox",
        "--disable-dev-shm-usage",
        "--disable-gpu",
        # Telefon-Format: so sieht es der Nutzer, für den die Fassung gebaut
        # ist.
        "--window-size=430,930",
    ]
    if GEGENPROBE:
        # Die Anleitungs-Texte kommen von dort. Gesperrt verhält sich der
        # Browser wie ohne Netz — genau der Zustand, den die Anleitungs-
        # Prüfungen erkennen müssen.
        chrome_args.append(
            "--host-resolver-rules=MAP raw.githubusercontent.com ~NOTFOUND")

    try:
        try:
            session = call("POST", "/session", {"capabilities": {"alwaysMatch": {
                "browserName": "chrome",
                "goog:chromeOptions": {"args": chrome_args},
            }}})["value"]["sessionId"]
        except Exception as error:
            melden("error", f"ChromeDriver nicht erreichbar: {error}")
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
            allen drei Sprachen anbieten.

            ⚠️ Erst genau, dann als Teiltreffer: Ein Semantik-Knoten trägt
            gelegentlich mehr als nur seine Beschriftung (ein Listeneintrag
            etwa Titel UND Untertitel). Ein Tipp, der deswegen nicht
            stattfindet, sieht aus wie eine kaputte Seite.
            """
            if any(tap(label, wait=wait) for label in labels):
                return True
            return any(tap(label, exact=False, wait=wait) for label in labels)

        def scroll_to(*labels, tries=8):
            """Scrollt, bis eine der Beschriftungen WIRKLICH im Sichtfeld liegt.

            ⚠️ Nicht „bis es sie im Baum gibt": Der Semantik-Baum führt auch
            Knoten unterhalb des Bildschirmrands, mit echten, aber
            unerreichbaren Koordinaten. Ein Tipp darauf landet auf der
            Navigationsleiste.

            ⚠️ Gescrollt wird mit einem **Rad**-Ereignis. Ein Wisch bewegt
            eine Flutter-Liste im Desktop-Browser nicht — die Seite bleibt
            stehen, ohne dass irgendetwas fehlschlägt.
            """
            nav_bar = js("return window.innerHeight;") - 90
            for _ in range(tries):
                for node in leaves():
                    if any(label in node["t"] for label in labels):
                        if 80 < node["y"] < nav_bar:
                            return True
                call("POST", f"/session/{session}/actions", {"actions": [{
                    "type": "wheel", "id": "wheel",
                    "actions": [{"type": "scroll", "x": 215, "y": 400,
                                 "deltaX": 0, "deltaY": 400,
                                 "duration": 200}],
                }]})
                time.sleep(1.5)
            return False

        def guide_cache():
            """Welche Anleitungs-Texte liegen im Browser-Speicher?

            Ein geglückter Abruf legt den Text unter `repo_content_<pfad>` ab.
            ⚠️ Den Text über den Semantik-Baum zu messen, geht NICHT: Von einer
            vollen Seite kommen dort nur rund 190 Zeichen an.
            """
            return str(js("""
              var out = [];
              Object.keys(localStorage).forEach(function(k){
                if (k.indexOf('repo_content_') >= 0)
                  out.push(k.split('repo_content_')[1] + ':' +
                           localStorage.getItem(k).length);
              });
              return out.join(', ');
            """))

        bestanden = [0]

        def check(name, condition, detail=""):
            print(f"  {'✓' if condition else '✗'} {name}{'  ' + detail if detail else ''}")
            if condition:
                bestanden[0] += 1
            else:
                failures.append(name)

        home = ("خانه", "Home")

        print(f"Prüfe: {URL}{'  (GEGENPROBE)' if GEGENPROBE else ''}\n")
        call("POST", f"/session/{session}/url", {"url": URL})

        # ⚠️ Kommt die App nicht hoch, wird ABGEBROCHEN — die folgenden
        # Prüfungen würden sonst dieselbe eine Ursache vielfach melden.
        if not boot():
            check("App startet", False)
            grund = diagnosis()
            print(f"\nABBRUCH: {grund}")
            melden("error", f"Browser-Durchgang: App kam nicht hoch. {grund}")
            return 1
        check("App startet und zeichnet", True, f"canvas={painted()}")

        # Erststart-Erklärung wegklicken. Der Knopf trägt je nach Sprache
        # einen anderen Text; „Root-in" steht in allen dreien.
        check("Erststart-Erklärung erscheint", shows("Root-in"))
        tap_any("رد کردن", "Überspringen", "Skip", wait=4)

        # ⚠️ **Danach steht der Speicher-Hinweis im Weg** (PLAN.md 26.8) — ein
        # modaler Dialog. Ohne ihn wegzuklicken ist KEIN Reiter erreichbar,
        # und der Durchgang meldet sechs rote Prüfungen für eine Ursache.
        # Genau daran ist sein erster Lauf gescheitert; `webtest.py` hatte
        # diesen Schritt, die CI-Fassung hatte ihn beim Abschreiben verloren.
        check("Speicher-Hinweis der Web-Fassung erscheint",
              shows("صفحهٔ اصلی", "Home-Bildschirm", "home screen"))
        tap_any("متوجه شدم", "Verstanden", "Got it", wait=3)

        storage = js("return Object.keys(localStorage).join(',');")
        check("Einstellungen landen im Browser-Speicher",
              "root_in.onboarding_seen" in storage, storage)

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

        # ------------------------------------------------------------------
        # Ab hier PLAN.md 31.2 — was `webtest.py` zusätzlich prüfte.
        # ------------------------------------------------------------------
        print()

        # ANLEITUNG. Die Rubrik steht weit unten in den Einstellungen —
        # ohne Scrollen tippt man auf die Navigationsleiste.
        planning = ("برنامه‌ریزی یادگیری", "Lernplanung", "Study planning")
        check("Rubrik „Root-in Anleitung“ ist erreichbar", scroll_to(*planning))
        tap_any(*planning)

        # ⚠️ „Getippt" ist nicht „geöffnet", und die Adresse hilft nicht: Die
        # Anleitung wird mit `push` geöffnet, die Adresse bleibt stehen. Der
        # Beweis ist eine UND-Verknüpfung — das Thema steht da UND die
        # Bottom-Navigation ist weg (die Anleitung liegt außerhalb der
        # Shell). Einzeln taugt keines von beiden.
        on_guide = wait_until(lambda: shows(*planning) and not shows(*home))
        check("Anleitungs-Seite ist wirklich offen", on_guide)

        # Der Text kommt über das Netz aus dem Repository. Gewartet wird auf
        # den Eintrag im Speicher, nicht auf die Uhr.
        cached = on_guide and wait_until(
            lambda: "lernplanung" in guide_cache().lower(), seconds=25)
        check(GUIDE_CACHED, cached, guide_cache())
        # ⚠️ Eine Abwesenheit — deshalb an `on_guide` gekoppelt. Erkannt wird
        # der Fehlerzustand am KNOPF, nicht an der Überschrift „Kein Internet".
        check(GUIDE_NO_RETRY, on_guide and not shows(
            "تلاش دوباره", "Erneut versuchen", "Try again"))

        # NEU LADEN. Die Anleitung hat keinen verlässlichen Weg zurück (die
        # Adresse ist beim `push` stehen geblieben) — und ein Neuladen prüft
        # nebenbei, dass der Erststart-Merker hält.
        call("POST", f"/session/{session}/url", {"url": URL})
        rebooted = boot()
        check("Nach dem Neuladen direkt in der App (Erststart-Merker hält)",
              rebooted and wait_until(lambda: shows(*home)))

        if rebooted:
            check("Reiter „Einstellungen“ (nach dem Neuladen)",
                  tap_any("تنظیمات", "Einstellungen", "Settings", wait=4))
            konto = ("اطلاعات حساب", "Konto-Infos", "Account info")
            check("Konto-Eintrag ist erreichbar", scroll_to(*konto))
            tap_any(*konto)
            # Die Konto-Seite liegt außerhalb der Shell. Zeuge, dass überhaupt
            # etwas gelesen wird: ein nicht leerer Semantik-Baum.
            on_account = wait_until(
                lambda: bool(leaves()) and not shows(*home))
            check("Konto-Seite ist offen (keine Bottom-Navigation mehr)",
                  on_account)

            # Die Karte erscheint erst, wenn der Anmeldestand feststeht —
            # deshalb gewartet. Ohne Warten liest man den Zustand davor.
            sign_in = on_account and wait_until(
                lambda: shows("ورود", "Anmelden", "Sign in"), seconds=10)
            if EXPECT_CLOUD or sign_in:
                check(CLOUD_SIGN_IN, sign_in)
            else:
                print("  – Rubrik „Konto & Cloud“ nicht vorhanden — Bau ohne "
                      "Supabase-Schlüssel (das ist dann richtig)")

        # DATENSCHUTZERKLÄRUNG (PLAN.md 29.5) — ohne Browser, sie ist eine
        # schlichte Seite neben der App.
        print()
        page, status = fetch(URL + "privacy.html")
        check(PRIVACY_REACHABLE, status == 200, f"HTTP {status}")
        check(PRIVACY_LANGUAGES, "Deine Rechte" in page and "Your rights" in page)
        # ⚠️ Eine Abwesenheit — nur mit dem Zeugen, dass die Seite da ist.
        check(PRIVACY_NO_NOTE, status == 200
              and "Datenschutzerklärung" in page
              and "INTERNE NOTIZ" not in page)

        print()
        return urteil(failures, bestanden[0])

    finally:
        if session:
            try:
                call("DELETE", f"/session/{session}")
            except Exception:
                pass
        driver.terminate()


if __name__ == "__main__":
    sys.exit(main())
