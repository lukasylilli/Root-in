#!/usr/bin/env python3
"""Macht aus `store/PRIVACY_POLICY.md` eine fertige Seite `build/web/privacy.html`.

Aufruf (macht `tool/build_web.sh` nach dem Flutter-Bau selbst):
    python3 tool/build_privacy_page.py build/web/privacy.html

Warum es dieses Skript gibt
---------------------------
Die Datenschutzerklärung **muss unter einer öffentlich erreichbaren Adresse
stehen** — nicht wegen eines Store-Formulars (den gibt es seit PLAN.md Phase 28
nicht mehr), sondern weil die App E-Mail-Adressen echter Nutzer speichert.

Bis Phase 29 lag die veröffentlichte Fassung in einem **GitHub-Gist**, der von
Hand nachgezogen werden musste. ⚠️ **Er war zweimal veraltet** — nach Phase 20
und nach Phase 27.8. Das ist kein Versäumnis einer Person, sondern die
vorhersehbare Folge einer zweiten Kopie: Wer eine Quelle zweimal pflegen muss,
pflegt sie irgendwann einmal. Genau davor warnt PLAN.md Abschnitt 9 („Puzzling"
/ DRY).

Die Seite entsteht deshalb **bei jedem Bau aus der einen Quelle** und wird mit
der App zusammen veröffentlicht:
    https://lukasylilli.github.io/Root-in/privacy.html
Damit kann sie gar nicht mehr veralten — eine Änderung an der Markdown-Datei
ist die Veröffentlichung.

Warum ein eigener Wandler statt `pip install markdown`
------------------------------------------------------
Dieselbe Überlegung wie bei `store/make_feature_graphic.py`, das seinerzeit PNG
selbst geschrieben hat, weil weder ImageMagick noch PIL da waren: Der Bau soll
von so wenig wie möglich abhängen. Die Automatik hat Python, sonst nichts —
und das Dokument benutzt genau sieben Markdown-Elemente (nachgezählt, nicht
geraten): Überschriften, Absätze, Listen, Tabellen, Trennlinien, **fett** und
`code`. Ein Wandler dafür ist kurz genug, um ihn zu lesen.

⚠️ **Wer die Markdown-Datei um ein Element erweitert, das hier fehlt** (Bilder,
Links in Klammer-Schreibweise, Blockzitate), bekommt es auf der Seite als
Rohtext zu sehen. `test/unit/privacy_page_test.dart` hält die Zusage fest,
dass die erzeugte Seite die tragenden Abschnitte wirklich enthält.
"""
import html
import pathlib
import re
import sys

QUELLE = pathlib.Path(__file__).resolve().parent.parent / "store" / "PRIVACY_POLICY.md"

# Markenfarbe wie in web/index.html — eine Quelle wäre schöner, aber die Seite
# soll ohne Stylesheet auskommen: Sie muss auch dann lesbar sein, wenn jemand
# nur diese eine Datei öffnet.
GRUEN = "#2E7D5B"

KOPF = f"""<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Root-in — Datenschutzerklärung / Privacy Policy</title>
<style>
  :root {{ color-scheme: light dark; }}
  body {{
    margin: 0 auto; padding: 24px 20px 64px; max-width: 46rem;
    font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    color: #1a1a1a; background: #fff;
  }}
  h1 {{ color: {GRUEN}; font-size: 1.6rem; margin: 0 0 1.5rem; }}
  h2 {{ color: {GRUEN}; font-size: 1.3rem; margin: 2.5rem 0 .75rem;
       border-bottom: 2px solid {GRUEN}33; padding-bottom: .25rem; }}
  h3 {{ font-size: 1.05rem; margin: 1.75rem 0 .5rem; }}
  table {{ border-collapse: collapse; width: 100%; margin: 1rem 0; font-size: .95rem;
          display: block; overflow-x: auto; }}
  th, td {{ border: 1px solid #ccc; padding: .5rem .6rem; text-align: left; vertical-align: top; }}
  th {{ background: {GRUEN}18; }}
  code {{ background: #eee; padding: .1rem .3rem; border-radius: 3px; font-size: .9em; }}
  hr {{ border: 0; border-top: 1px solid #ddd; margin: 2.5rem 0; }}
  ul {{ padding-left: 1.2rem; }}
  li {{ margin: .35rem 0; }}
  a {{ color: {GRUEN}; }}
  @media (prefers-color-scheme: dark) {{
    body {{ color: #e8e8e8; background: #161616; }}
    th, td {{ border-color: #444; }}
    code {{ background: #2a2a2a; }}
    hr {{ border-top-color: #333; }}
    h1, h2, a {{ color: #6ecfa0; }}
    th {{ background: #223d31; }}
  }}
</style>
</head>
<body>
"""

FUSS = "</body>\n</html>\n"


def inline(text: str) -> str:
    """**fett**, `code` und nackte URLs — in dieser Reihenfolge.

    ⚠️ Erst maskieren, dann Auszeichnungen einsetzen. Andersherum würde
    `html.escape` die gerade erzeugten Tags gleich wieder unschädlich machen.
    """
    out = html.escape(text, quote=False)
    out = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", out)
    # Kursiv ERST nach fett: Sonst frisst das einfache Sternchen die Hälfte
    # eines `**`-Paares und beide Auszeichnungen brechen.
    out = re.sub(r"\*([^*\n]+?)\*", r"<em>\1</em>", out)
    out = re.sub(r"`([^`]+)`", r"<code>\1</code>", out)
    # Nackte Adressen anklickbar machen. Ein abschließender Satzpunkt gehört
    # nicht mehr zur Adresse — sonst führt jeder Link am Satzende ins Leere.
    out = re.sub(
        r"(https?://[^\s<]+?)([.,;:]?)(?=\s|$)",
        r'<a href="\1">\1</a>\2',
        out,
    )
    return out


def umwandeln(markdown: str) -> str:
    """Markdown → HTML für genau die Elemente, die das Dokument benutzt."""
    # ⚠️ Der HTML-Kommentar am Dateiende ist eine INTERNE NOTIZ und darf nicht
    # veröffentlicht werden. Er steht dort bewusst als Kommentar, damit sich
    # die Datei gefahrlos komplett kopieren lässt — hier wird er hart
    # abgeschnitten, statt sich darauf zu verlassen, dass ein Browser ihn
    # versteckt.
    markdown = markdown.split("<!--")[0]

    zeilen = markdown.split("\n")
    teile: list[str] = []
    absatz: list[str] = []
    liste: list[str] = []
    tabelle: list[list[str]] = []

    def absatz_schliessen() -> None:
        if absatz:
            teile.append("<p>" + inline(" ".join(absatz)) + "</p>")
            absatz.clear()

    def liste_schliessen() -> None:
        if liste:
            teile.append("<ul>" + "".join(f"<li>{inline(x)}</li>" for x in liste) + "</ul>")
            liste.clear()

    def tabelle_schliessen() -> None:
        if not tabelle:
            return
        kopf, *rest = tabelle
        # Die Trennzeile (|---|---|) ist keine Datenzeile.
        rest = [r for r in rest if not all(set(z.strip()) <= set("-: ") for z in r)]
        zellen = lambda r, tag: "".join(f"<{tag}>{inline(z)}</{tag}>" for z in r)
        teile.append(
            "<table><thead><tr>" + zellen(kopf, "th") + "</tr></thead><tbody>"
            + "".join("<tr>" + zellen(r, "td") + "</tr>" for r in rest)
            + "</tbody></table>"
        )
        tabelle.clear()

    def alles_schliessen() -> None:
        absatz_schliessen(); liste_schliessen(); tabelle_schliessen()

    for zeile in zeilen:
        roh = zeile.rstrip()

        if roh.startswith("|"):
            absatz_schliessen(); liste_schliessen()
            tabelle.append([z.strip() for z in roh.strip("|").split("|")])
            continue
        tabelle_schliessen()

        if not roh.strip():
            absatz_schliessen(); liste_schliessen()
            continue

        if re.fullmatch(r"-{3,}", roh.strip()):
            alles_schliessen(); teile.append("<hr>")
            continue

        ueberschrift = re.match(r"(#{1,6})\s+(.*)", roh)
        if ueberschrift:
            alles_schliessen()
            stufe = len(ueberschrift.group(1))
            teile.append(f"<h{stufe}>{inline(ueberschrift.group(2))}</h{stufe}>")
            continue

        if roh.startswith("- "):
            absatz_schliessen()
            liste.append(roh[2:])
            continue
        # ⚠️ Eingerückte FOLGEZEILE eines Listenpunkts. Ohne diesen Zweig
        # endete der Punkt am Zeilenende, und eine Auszeichnung, die über
        # zwei Zeilen geht, blieb als Rohtext stehen — gefunden am Satz
        # „**Safari löscht den Speicher … nach sieben Tagen ohne / Besuch.**",
        # dessen Sternchen mitten auf der Seite standen.
        if liste and zeile.startswith(("  ", "\t")):
            liste[-1] += " " + roh.strip()
            continue
        liste_schliessen()

        # ⚠️ Eine Zeile im Muster `**Label:** Wert` beginnt einen EIGENEN
        # Absatz. Ohne diese Regel liefen die drei Kopfzeilen (Verantwortlich,
        # Kontakt, Stand) und die vier Erklärzeilen in Punkt 4 zu einer
        # einzigen Textwurst zusammen — bei einem Text, den Nutzer im Zweifel
        # als Rechtsauskunft lesen, ist das nicht nur unschön.
        if re.match(r"\*\*[^*]+?:\*\*", roh.strip()):
            absatz_schliessen()
        absatz.append(roh.strip())

    alles_schliessen()
    return "\n".join(teile) + "\n"


def main() -> int:
    ziel = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "build/web/privacy.html")
    if not QUELLE.exists():
        print(f"FEHLER: {QUELLE} fehlt.", file=sys.stderr)
        return 1

    seite = KOPF + umwandeln(QUELLE.read_text(encoding="utf-8")) + FUSS
    ziel.parent.mkdir(parents=True, exist_ok=True)
    ziel.write_text(seite, encoding="utf-8")
    print(f"  {ziel} ✓ ({len(seite):,} Zeichen)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
