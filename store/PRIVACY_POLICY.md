# Root-in — Datenschutzerklärung / Privacy Policy

---

## Deutsch

**Verantwortlich:** Saleh Aliramezani, Dornbirn, Österreich
**Kontakt:** alirzsaleh@gmail.com · Telegram: https://t.me/LukasAlmani
**Stand:** August 2026 (Web-Fassung)

### Kurzfassung

Root-in ist eine **Web-App**: Sie läuft im Browser, es gibt nichts zu
installieren. Deine Gewohnheiten, Erledigungen, Statistiken und dein Profil
liegen **im Speicher deines Browsers auf deinem Gerät** (Einzelheiten in
Punkt 5). Die App ist ohne Konto vollständig benutzbar — und ohne Konto
verlassen diese Daten dein Gerät nicht.

**Neu: Du kannst freiwillig ein Konto anlegen.** Dann liegt zusätzlich eine
**Kopie** deiner Daten auf einem Server, damit du sie nach einem Geräteverlust
oder einer Neuinstallation zurückholen kannst. Was dabei gespeichert wird und
wie du es wieder loswirst, steht in Punkt 4.

Die App enthält **keine Werbung** und **keine In-App-Käufe**. Es wird **keine
Werbe-ID** und keine andere Kennung deines Geräts erhoben. Deine Daten werden
**nicht** verkauft, nicht analysiert und nicht an Dritte weitergegeben.

### 1. Daten, die auf deinem Gerät bleiben

Die App legt lokal in einer Datenbank auf deinem Gerät ab:

- Gewohnheiten, Kategorien und deren Einstellungen
- Abgehakte Tage, Dauer-/Mengenangaben, daraus berechnete Serien und Punkte
- Deinen im Profil eingetragenen Namen
- App-Einstellungen (Sprache, Darstellungsmodus, Farbschema, Layouts)

Ohne Konto werden diese Daten **nicht** an uns oder an Dritte übertragen. Sie
werden gelöscht, sobald du die Website-Daten in deinem Browser löschst (siehe
Punkt 5). Mit Konto gilt zusätzlich Punkt 4.

### 2. Datumsprüfung im Internet

Um zu verhindern, dass Serien („Streaks") durch ein manuelles Verstellen der
Geräteuhr verfälscht werden, ruft die App gelegentlich die Startseite von
Google auf und liest daraus **ausschließlich das Datum aus dem HTTP-Header**.
Dabei werden keine persönlichen Daten übermittelt und keine Inhalte
gespeichert. Ohne Internetverbindung nutzt die App die lokale Gerätezeit.

### 3. Anleitungs-Texte aus dem Internet

Die Texte der Rubrik „Root-in Anleitung" liegen nicht in der App, sondern in
einem öffentlichen GitHub-Repository; die App lädt sie dort als reine
Textdateien und legt sie auf deinem Gerät ab, damit sie auch offline lesbar
sind. Übertragen wird dabei nur, was jeder Web-Abruf mit sich bringt (u. a.
deine IP-Adresse gegenüber GitHub). Es werden **keine** Daten über dich, deine
Gewohnheiten oder deine Nutzung gesendet. Anbieter ist GitHub, Inc.; es gilt
deren Datenschutzerklärung: https://docs.github.com/site-policy

### 4. Konto und Sicherung auf dem Server (freiwillig)

**Ohne Konto passiert nichts davon.** Die App ist vollständig benutzbar, ohne
dass du dich registrierst; es gibt dann keine Verbindung zu unserem Server.

Legst du ein Konto an, speichern wir:

| Was | Wozu |
|---|---|
| **E-Mail-Adresse** | Anmeldung und — sobald eingerichtet — das Zurücksetzen eines vergessenen Passworts. Sonst nichts: keine Newsletter, keine Werbung |
| **Passwort** | nur als kryptografischer Hash. Wir können es **nicht** lesen |
| **Benutzername** und Anzeigename | damit dein Konto einen Namen hat |
| **Eine Kopie deiner App-Daten** | Gewohnheiten, Kategorien und abgehakte Tage — dieselben Angaben wie in einem Export |

**Wo das liegt:** bei Supabase (Datenbank in der EU, Region Frankfurt).
Auftragsverarbeiter ist Supabase Inc.; es gilt zusätzlich deren
Datenschutzerklärung: https://supabase.com/privacy

**Wer es sehen kann:** nur du. Der Server gibt jede Zeile ausschließlich an
das angemeldete Konto heraus, dem sie gehört (technisch abgesichert über
Zugriffsregeln in der Datenbank). Wir sehen deine Gewohnheiten nicht an und
werten sie nicht aus.

**Wann hochgeladen wird:** automatisch nach Änderungen, solange du angemeldet
bist. Heruntergeladen wird **nur**, wenn du es ausdrücklich verlangst.

**Wie du es wieder loswirst:** In der App unter *Einstellungen → Konto →
Konto & Cloud* kannst du deine Daten auf dem Server löschen und dich
abmelden. Eine vollständige Löschung deines Kontos veranlassen wir auf Zuruf
an alirzsaleh@gmail.com — wir bestätigen sie dir.

### 4b. Eigener Export

Unabhängig davon kannst du deine Daten jederzeit als Datei exportieren. Wohin
diese Datei geht, entscheidest **allein du** über die Teilen-Funktion deines
Geräts. Dasselbe gilt für das Bild deines Fortschritts.

### 5. Wo deine Daten im Browser liegen

Root-in ist eine **Web-App** — sie läuft im Browser und wird nicht installiert.
Deine Daten liegen deshalb im Speicher, den dein Browser dieser Seite zuweist
(IndexedDB bzw. OPFS für die Datenbank, „localStorage" für Einstellungen). Sie
verlassen deinen Browser nicht.

Drei Dinge, die daraus folgen und die du wissen solltest:

- **„Website-Daten löschen" löscht deinen Bestand.** Das ist derselbe Knopf,
  mit dem du Browser-Daten aufräumst — er unterscheidet nicht zwischen Root-in
  und anderen Seiten.
- ⚠️ **Safari löscht den Speicher einer Website nach sieben Tagen ohne
  Besuch.** Legst du Root-in über „Zum Home-Bildschirm" ab, gilt das nicht
  mehr. Die App weist beim ersten Start einmal darauf hin.
- **Ein anderes Gerät oder ein anderer Browser hat einen eigenen Bestand.**
  Übertragen kannst du ihn über den Export (Punkt 4b) oder über ein Konto
  (Punkt 4).

Die App bittet den Browser beim Start darum, diesen Speicher dauerhaft zu
behalten. Das ist eine Bitte, keine Garantie — die Entscheidung trifft dein
Browser.

### 6. Berechtigungen

Root-in fragt **keine Geräte-Berechtigungen** ab: keine Benachrichtigungen,
keinen Standort, keine Kontakte, keine Kamera, kein Mikrofon. Es gibt auch
keine Werbe-ID.

⚠️ **Erinnerungen gibt es nicht.** Frühere Fassungen dieser Erklärung nannten
Benachrichtigungen und eine Berechtigung dafür; beides ist entfallen, weil es
die App nur noch als Web-Fassung gibt und ein Browser keine Weckzeiten stellen
kann.

### 7. Kinder

Die App richtet sich nicht gezielt an Kinder unter 13 Jahren. Wir erheben
wissentlich keine personenbezogenen Daten von Kindern.

### 8. Deine Rechte

**Ohne Konto** speichern wir nichts über dich; es gibt dann auch nichts
herauszugeben oder zu löschen. Deine Daten löschst du, indem du die
Website-Daten in deinem Browser löschst (Punkt 5).

**Mit Konto** hast du die Rechte aus der DSGVO — Auskunft, Berichtigung,
Löschung, Datenübertragbarkeit und Widerspruch. In der Praxis:

- **Auskunft und Übertragbarkeit:** Der Export in der App liefert dir denselben
  Datenbestand, der auf dem Server liegt — als lesbare JSON-Datei.
- **Berichtigung:** Name und E-Mail änderst du in der App.
- **Löschung:** In der App löschst du die Server-Kopie und meldest dich ab;
  für die vollständige Löschung des Kontos schreib an alirzsaleh@gmail.com.
- **Rechtsgrundlage** ist deine Einwilligung (Art. 6 Abs. 1 lit. a DSGVO) —
  du gibst sie, indem du ein Konto anlegst, und ziehst sie zurück, indem du es
  löschst.

Beschweren kannst du dich bei der österreichischen Datenschutzbehörde
(dsb.gv.at).

### 9. Änderungen

Bei Änderungen dieser Erklärung aktualisieren wir das oben genannte Datum.

### 10. Kontakt

alirzsaleh@gmail.com · https://t.me/LukasAlmani

---

## English

**Controller:** Saleh Aliramezani, Dornbirn, Austria
**Contact:** alirzsaleh@gmail.com · Telegram: https://t.me/LukasAlmani
**Last updated:** August 2026

### Summary

Root-in is a **web app**: it runs in your browser, there is nothing to
install. Your habits, completions, statistics and profile live **in your
browser's storage on your device** (details in section 5). The app is fully usable without an account — and without an account
that data never leaves your device.

**New: you may optionally create an account.** A **copy** of your data is then
kept on a server so you can get it back after losing your device or
reinstalling. What is stored and how to get rid of it is in section 4.

The app contains **no advertising** and **no in-app purchases**. **No
Advertising ID** and no other device identifier is collected. Your data is
**not** sold, not analysed and not passed on to third parties.

### 1. Data that stays on your device

The app stores locally, in a database on your device:

- Habits, categories and their settings
- Completed days, duration/quantity entries, and the streaks and points
  derived from them
- The name you enter in your profile
- App settings (language, appearance mode, colour scheme, layouts)

Without an account this data is **not** transmitted to us or to any third
party. It is deleted as soon as you clear this site's data in your browser
(see section 5). With an
account, section 4 applies in addition.

### 2. Online date check

To prevent streaks from being falsified by manually changing the device clock,
the app occasionally contacts Google's homepage and reads **only the date from
the HTTP header**. No personal data is transmitted and no content is stored.
Without an internet connection the app uses the local device time.

### 3. Guide texts from the internet

The texts in the "Root-in guide" section are not bundled with the app but live
in a public GitHub repository; the app downloads them as plain text files and
stores them on your device so they remain readable offline. The only data
transmitted is what any web request entails (your IP address towards GitHub,
among others). **No** data about you, your habits or your usage is sent. The
provider is GitHub, Inc.; their privacy statement applies:
https://docs.github.com/site-policy

### 4. Account and server backup (optional)

**Without an account none of this happens.** The app is fully usable without
signing up; there is then no connection to our server at all.

If you create an account, we store:

| What | Why |
|---|---|
| **Email address** | Sign-in and — once configured — resetting a forgotten password. Nothing else: no newsletters, no advertising |
| **Password** | only as a cryptographic hash. We **cannot** read it |
| **Username** and display name | so your account has a name |
| **A copy of your app data** | habits, categories and completed days — the same content as an export |

**Where it lives:** with Supabase (database in the EU, Frankfurt region). The
processor is Supabase Inc.; their privacy statement applies in addition:
https://supabase.com/privacy

**Who can see it:** only you. The server hands out each row exclusively to the
signed-in account it belongs to (enforced by access rules in the database). We
do not look at your habits and do not analyse them.

**When it is uploaded:** automatically after changes while you are signed in.
It is downloaded **only** when you explicitly ask for it.

**How to get rid of it:** in the app under *Settings → Account → Account &
cloud* you can delete your server data and sign out. For full deletion of the
account, write to alirzsaleh@gmail.com — we will confirm it.

### 4b. Your own export

Independently of this, you can export your data as a file at any time. Where
that file goes is decided **by you alone**, via your device's share function.
The same applies to the progress image you create via "Share progress".

### 5. Where your data lives in the browser

Root-in is a **web app** — it runs in your browser and is not installed. Your
data therefore lives in the storage your browser assigns to this site
(IndexedDB or OPFS for the database, `localStorage` for settings). It does not
leave your browser.

Three consequences worth knowing:

- **"Clear website data" deletes your records.** It is the same button you use
  to tidy up browser data; it does not distinguish Root-in from other sites.
- ⚠️ **Safari deletes a website's storage after seven days without a visit.**
  If you add Root-in via "Add to Home Screen", that no longer applies. The app
  points this out once on first start.
- **Another device or another browser has its own records.** You can move them
  via the export (section 4b) or via an account (section 4).

On startup the app asks the browser to keep this storage permanently. That is
a request, not a guarantee — your browser decides.

### 6. Permissions

Root-in requests **no device permissions**: no notifications, no location, no
contacts, no camera, no microphone. There is no advertising ID either.

⚠️ **There are no reminders.** Earlier versions of this policy mentioned
notifications and a permission for them; both are gone, because the app now
exists only as a web version and a browser cannot set alarms.

### 7. Children

The app is not directed at children under 13. We do not knowingly collect
personal data from children.

### 8. Your rights

**Without an account** we store nothing about you, so there is nothing to hand
over or delete. Delete your data by clearing this site's data in your browser
(section 5).

**With an account** you have the rights granted by the GDPR — access,
rectification, erasure, portability and objection. In practice:

- **Access and portability:** the export in the app gives you the same data
  that sits on the server, as a readable JSON file.
- **Rectification:** change your name and email in the app.
- **Erasure:** delete the server copy and sign out in the app; for full
  deletion of the account, write to alirzsaleh@gmail.com.
- **Legal basis** is your consent (Art. 6(1)(a) GDPR) — given by creating an
  account, withdrawn by deleting it.

You may lodge a complaint with the Austrian data protection authority
(dsb.gv.at).

### 9. Changes

If this policy changes, we will update the date shown above.

### 10. Contact

alirzsaleh@gmail.com · https://t.me/LukasAlmani

<!--
=====================================================================
INTERNE NOTIZ — NICHT TEIL DER VERÖFFENTLICHTEN ERKLÄRUNG.
Steht bewusst als HTML-Kommentar am Dateiende: Markdown-Renderer
(GitHub, Gist) blenden ihn aus, das ganze Dokument lässt sich also
gefahrlos komplett kopieren.

**Stand 2026-08-17 (PLAN.md Phase 28).** Inhaltlich abgeleitet aus dem
tatsächlichen Verhalten der App, nicht aus einer Vorlage. Vor der
Veröffentlichung bitte lesen und prüfen — dies ist keine Rechtsberatung.

**Muss unter einer öffentlich erreichbaren URL liegen.** Der Grund ist seit
Phase 28 nicht mehr die Play Console (es gibt keine Store-Veröffentlichung
mehr), sondern schlicht: Wer die Adresse an Schüler gibt und deren E-Mail
speichert, schuldet ihnen einen zutreffenden, erreichbaren Text.

✅ **Seit 2026-09-12 (PLAN.md 29.5) veröffentlicht sich diese Datei selbst:**
`tool/build_privacy_page.py` macht bei jedem Bau daraus
https://lukasylilli.github.io/Root-in/privacy.html — diese Notiz wird dabei
abgeschnitten. Der frühere Gist ist überholt und soll gelöscht werden:
https://gist.github.com/lukasylilli/673c36972d69819d975ffb82a592cca2

Änderungen 2026-08-17 (Phase 28) — die Fassung wurde auf **Web-only**
umgestellt:
- **Abschnitt „Automatische Sicherung durch Android" ersatzlos gestrichen.**
  Es gibt keine Android-Fassung mehr; der Absatz beschrieb einen Vorgang, den
  es für Nutzer dieser App nicht gibt.
- **Abschnitt „Benachrichtigungen" gestrichen** und die Berechtigungs-Liste
  ersetzt: Root-in fragt jetzt **gar keine** Geräte-Berechtigungen ab. Der
  neue Text sagt ausdrücklich, dass es **keine Erinnerungen** gibt — eine
  Erklärung, die eine nicht vorhandene Funktion beschreibt, ist so falsch wie
  eine, die eine vorhandene verschweigt.
- **Neuer Abschnitt 5 „Wo deine Daten im Browser liegen"** — der wichtigste
  Zugewinn dieser Überarbeitung. Er nennt, was den Nutzer wirklich betrifft:
  „Website-Daten löschen" räumt den Bestand ab, **Safari löscht den Speicher
  nach sieben Tagen ohne Besuch** (nicht bei einer auf dem Home-Bildschirm
  abgelegten Fassung), und jedes Gerät hat einen eigenen Bestand.
- Kurzfassung, Löschhinweise und Rechte-Abschnitt sprechen nicht mehr von
  „App deinstallieren", sondern vom Browser-Speicher.
- Folgeabschnitte neu nummeriert (7–10 statt 8–11), beide Sprachen.

Frühere Änderungen (Juli → August 2026):
- Abschnitte „Werbung (Google AdMob)" und „In-App-Kauf (Google Play Billing)"
  entfallen (Phase 20); Berechtigung „Werbe-ID" gestrichen.
- Abschnitt zu den Anleitungs-Texten aus dem GitHub-Repository (Phase 17.1).
- Teilen-Abschnitt nennt zusätzlich das Fortschritts-Bild (Phase 19).
- **Phase 27.8:** Punkt 4 (Konto und Server-Sicherung, Supabase EU/Frankfurt)
  und ein neu geschriebener Rechte-Abschnitt — „wir speichern nichts" war mit
  Konto schlicht falsch.
=====================================================================
-->
