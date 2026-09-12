import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/constants/app_links.dart';

/// PLAN.md Phase 27.11 — der geteilte Link.
///
/// **Wie der Fehler entstanden ist, den dieser Test verhindern soll:** Die
/// Fortschritts-Karte trug den Play-Store-Link, obwohl die App dort nie
/// veröffentlicht wurde. Jeder geteilte QR-Code führte auf eine
/// „nicht gefunden"-Seite von Google. Aufgefallen ist es niemandem im Code —
/// der bestehende Test prüfte die **Konstante** (`playStoreUrl` ist die
/// richtige Play-Adresse, das stimmte ja), nicht die Frage, ob die Karte den
/// **richtigen** Link trägt.
///
/// ⚠️ Ein Link in einem geteilten Bild ist besonders unbarmherzig: Das Bild
/// bleibt in Chats liegen, und wer den Code scannt und eine Fehlerseite
/// bekommt, probiert es kein zweites Mal — und meldet es auch nicht.
///
/// ⚠️ **Seit Phase 28 gibt es nur noch die Web-Fassung**, `playStoreUrl` und
/// `appPackageName` sind entfallen. Der Test bleibt trotzdem: Er hält fest,
/// dass geteilt wird, was auch wirklich erreichbar ist.
void main() {
  test('geteilt wird die Web-Fassung', () {
    expect(appShareUrl, webAppUrl);
  });

  test('die Datenschutzerklärung liegt neben der App', () {
    // ⚠️ Sie MUSS unter derselben Adresse liegen wie die App: Nur dann
    // entsteht sie bei jedem Bau aus `store/PRIVACY_POLICY.md` mit und kann
    // nicht mehr veralten. Zeigt sie wieder woandershin (Gist, eigene
    // Domain), ist die zweite Kopie zurück — und mit ihr der Fehler, der sie
    // zweimal veralten ließ (PLAN.md 29.5).
    expect(privacyPolicyUrl, startsWith(webAppUrl));
    expect(privacyPolicyUrl, endsWith('privacy.html'));
  });

  test('die Web-Adresse ist vollständig und aufrufbar geformt', () {
    final uri = Uri.parse(appShareUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, isNotEmpty);
    // Ohne den Pfad landet man auf der GitHub-Seite des Nutzers, nicht auf
    // Root-in — dieselbe Falle wie `--base-href` (Lehre 28).
    expect(uri.path, isNot('/'));
  });
}
