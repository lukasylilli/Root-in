/// Einzige Quelle der öffentlichen Links der App (siehe PLAN.md Phase 19).
///
/// Kein anderer Ort baut eine Adresse zusammen: die Fortschritts-Karte
/// (QR-Code), der Begleittext des Share-Sheets und „App teilen" in den
/// Einstellungen lesen alle hier. Ändert sich die Adresse, ändert sie sich an
/// einer Stelle.
library;

/// Paketname der App — nach der Veröffentlichung unveränderlich. Muss zur
/// `applicationId` in `android/app/build.gradle.kts` passen.
const String appPackageName = 'com.rootin.app';

/// Die **Web-Fassung** — seit Phase 26 veröffentlicht und für jeden erreichbar.
///
/// Die Adresse ergibt sich aus dem GitHub-Benutzer und dem Repository-Namen;
/// dieselben zwei Werte stecken im `--base-href` des Bau-Skripts.
const String webAppUrl = 'https://lukasylilli.github.io/Root-in/';

/// Play-Store-Seite der App.
///
/// ⚠️ **Führt erst nach der Veröffentlichung irgendwohin** (PLAN.md Phase
/// 15.6). Vorher antwortet Google mit „nicht gefunden". Deshalb steht sie
/// hier bereit, wird aber **nicht geteilt** — siehe [appShareUrl].
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=$appPackageName';

/// **Die Adresse, die geteilt wird** — im QR-Code der Fortschritts-Karte, im
/// Begleittext des Share-Sheets und bei „App teilen".
///
/// Das ist die Web-Fassung, und zwar aus zwei Gründen:
///
/// 1. ⚠️ **Der Play-Link war schlicht falsch.** Solange die App nicht
///    veröffentlicht ist, führte jeder geteilte QR-Code auf eine
///    „nicht gefunden"-Seite. Ein geteiltes Bild bleibt in Chats liegen; ein
///    Link darin, der ins Leere führt, macht die Karte wertlos — und niemand
///    meldet es, man probiert es einmal und lässt es.
/// 2. **Sie funktioniert auf jedem Gerät.** Ein Play-Link schließt genau die
///    iPhone-Nutzer aus, für die die Web-Fassung überhaupt gebaut wurde
///    (Phase 26). Wer die Karte teilt, weiß nicht, was der Empfänger benutzt.
///
/// **Auch nach einer Play-Veröffentlichung bleibt das vermutlich richtig:**
/// Die Web-Fassung erreicht alle, die Play-Seite nur Android. Wer dann doch
/// auf den Store zeigen will, ändert genau diese eine Zeile — und alle drei
/// Leser ziehen mit.
const String appShareUrl = webAppUrl;
