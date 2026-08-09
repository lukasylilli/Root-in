# Rubrik „موارد دیگر" — Anleitung zum Pflegen

> Gehört zu PLAN.md Phase 22. Diese Datei erklärt, wie der Kanal im
> GitHub-Repository gepflegt wird. Sie ist **nicht** Teil der App.

## Inhaltsverzeichnis
1. [Wo die Dateien liegen](#1-wo-die-dateien-liegen)
2. [Die Manifest-Datei `index.json`](#2-die-manifest-datei-indexjson)
3. [Einen Beitrag hinzufügen](#3-einen-beitrag-hinzufügen)
4. [Was passiert, wenn etwas fehlt](#4-was-passiert-wenn-etwas-fehlt)
5. [Häufige Fehler](#5-häufige-fehler)

## 1. Wo die Dateien liegen

Im Repository `lukasylilli/Root-in`, Branch `main`:

```
content/others/fa/index.json
content/others/fa/<ordner>/<datei>.md
content/others/en/…
content/others/de/…
```

**Je Sprache ein eigener Satz.** Ein Nutzer mit persischer App sieht nur
`fa`, mit deutscher nur `de`. Es gibt keinen Rückfall zwischen den Sprachen:
Fehlt `content/others/de/index.json`, bleibt die Rubrik für deutsche Nutzer
leer — sie sehen „Inhalt folgt", keinen Fehler.

## 2. Die Manifest-Datei `index.json`

Sie ist die **einzige** Quelle der Struktur. GitHubs Rohdateien-Adresse kann
keine Ordner auflisten, und die GitHub-API erlaubt ohne Anmeldung nur 60
Abrufe pro Stunde und IP-Adresse — mehrere Nutzer hinter derselben
Mobilfunk-Adresse sähen die Rubrik zeitweise leer. Deshalb diese Datei.

Vollständiges Beispiel: `store/others_index_beispiel.json`.

| Feld | Pflicht | Bedeutung |
|---|---|---|
| `folders[].id` | ja | Stabiler Schlüssel, steht in der Adresse der Seite. **Nicht ändern**, sonst geht ein offener Ordner beim Nutzer verloren |
| `folders[].title` | ja | Was auf dem Knopf steht. Freier Text — Emoji und persische Schrift ausdrücklich erlaubt |
| `folders[].order` | nein | Kleinere Zahl steht oben. Fehlt sie, landet der Ordner unten |
| `folders[].folder_path` | nein | Nur zur Übersicht; die App liest ihn nicht (der Pfad steht vollständig in `file_path`) |
| `folders[].files[].title` | ja | Überschrift des Beitrags in der Liste |
| `folders[].files[].file_path` | ja | Pfad der `.md`-Datei **relativ zum Sprachordner, mit Ordnername**, z. B. `news/start.md` |

`file_path` enthält den Ordner bewusst mit: So setzt die App nichts zusammen,
und ein Beitrag kann später in einen anderen Ordner ziehen, ohne dass das
Schema bricht.

## 3. Einen Beitrag hinzufügen

1. Die Markdown-Datei hochladen, z. B. `content/others/fa/news/2026-08-start.md`.
2. In `content/others/fa/index.json` beim passenden Ordner zwei Zeilen
   ergänzen:

```json
{ "title": "شروع دورهٔ تابستان", "file_path": "news/2026-08-start.md" }
```

Mehr nicht — **kein App-Update nötig**. Die App zeigt beim nächsten Öffnen
den gespeicherten Stand sofort an und lädt daneben nach; hat sich etwas
geändert, baut sie die Seite neu auf.

⚠️ GitHub liefert Rohdateien mit `max-age=300` aus. Bis zu **fünf Minuten**
nach dem Hochladen kann die App noch den alten Stand zeigen. Das ist kein
Fehler.

## 4. Was passiert, wenn etwas fehlt

| Fall | Was der Nutzer sieht |
|---|---|
| `index.json` gibt es nicht (404) | „Inhalt folgt" — ein leerer Kanal, kein Fehler |
| `index.json` ist kaputt | „Inhalt nicht lesbar" mit einem Knopf „Erneut versuchen" |
| Ein Ordner hat keine Dateien | „Noch kein Beitrag" |
| Eine `.md`-Datei fehlt, steht aber im Manifest | „Inhalt folgt" — nur an dieser Stelle, der Rest bleibt lesbar |
| Kein Internet, nichts gespeichert | „Kein Internet" mit „Erneut versuchen" |
| Kein Internet, aber schon einmal geladen | Der gespeicherte Stand — die Rubrik ist offline lesbar |

## 5. Häufige Fehler

- **Komma zu viel oder zu wenig.** JSON verzeiht das nicht; die App meldet
  dann „Inhalt nicht lesbar". Vor dem Hochladen einmal durch einen
  JSON-Prüfer schicken.
- **`file_path` ohne Ordnername** (`start.md` statt `news/start.md`). Die
  Datei wird dann unter dem Sprachordner gesucht und nicht gefunden → an
  dieser Stelle steht „Inhalt folgt".
- **`id` nachträglich geändert.** Wer den Ordner gerade offen hat, landet auf
  „Inhalt folgt". Den Titel darf man jederzeit ändern, die `id` besser nie.
- **Datei in `de/` abgelegt, aber im `fa/index.json` eingetragen.** Die
  Sprachen sind vollständig getrennt.
