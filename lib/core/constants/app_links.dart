/// Einzige Quelle der öffentlichen Links der App (siehe PLAN.md Phase 19).
///
/// Kein anderer Ort baut eine Adresse zusammen: die Fortschritts-Karte
/// (QR-Code), der Begleittext des Share-Sheets und „App teilen" in den
/// Einstellungen lesen alle hier. Ändert sich die Adresse, ändert sie sich an
/// einer Stelle.
library;

/// Die **Web-Fassung** — und seit PLAN.md Phase 28 die einzige Fassung.
///
/// Die Adresse ergibt sich aus dem GitHub-Benutzer und dem Repository-Namen;
/// dieselben zwei Werte stecken im `--base-href` des Bau-Skripts.
const String webAppUrl = 'https://lukasylilli.github.io/Root-in/';

/// **Die Adresse, die geteilt wird** — im QR-Code der Fortschritts-Karte, im
/// Begleittext des Share-Sheets und bei „App teilen".
///
/// ⚠️ **Sie ist bewusst identisch mit [webAppUrl] und trotzdem eine eigene
/// Konstante.** Bis Phase 27.11 stand hier ein Play-Store-Link — für eine App,
/// die dort nie veröffentlicht wurde. Jeder geteilte QR-Code führte auf eine
/// „nicht gefunden"-Seite, und weil ein geteiltes Bild in Chats liegen bleibt,
/// war der Schaden still und dauerhaft: Wer einmal auf einer Fehlerseite
/// landet, probiert es kein zweites Mal und meldet es auch nicht.
///
/// Der Name sagt, wofür die Adresse **da** ist, nicht wo sie hinzeigt. Käme je
/// ein zweiter Zugang dazu, ändert sich genau diese Zeile — und alle drei
/// Leser ziehen mit.
const String appShareUrl = webAppUrl;

/// Die **veröffentlichte Datenschutzerklärung** (PLAN.md 29.5).
///
/// Sie liegt neben der App und entsteht bei jedem Bau aus derselben einen
/// Quelle (`store/PRIVACY_POLICY.md`, gewandelt von
/// `tool/build_privacy_page.py`).
///
/// ⚠️ **Deshalb kann sie nicht mehr veralten.** Vorher lag die
/// veröffentlichte Fassung in einem von Hand gepflegten GitHub-Gist — und
/// war **zweimal** veraltet, nach Phase 20 und nach Phase 27.8. Nicht aus
/// Nachlässigkeit: Eine zweite Kopie, die jemand nachziehen muss, wird
/// irgendwann nicht nachgezogen. Eine Änderung an der Markdown-Datei **ist**
/// jetzt die Veröffentlichung.
const String privacyPolicyUrl = '${webAppUrl}privacy.html';
