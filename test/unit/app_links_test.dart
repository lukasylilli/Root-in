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
void main() {
  test('geteilt wird die Web-Fassung, nicht der Play-Store', () {
    // Wer diese Zeile ändert, ändert sie bewusst: Der Play-Link darf erst
    // hier stehen, wenn die App dort **wirklich** veröffentlicht ist
    // (PLAN.md Phase 15.6). Vorher ist er eine Sackgasse.
    expect(appShareUrl, webAppUrl);
    expect(appShareUrl, isNot(playStoreUrl));
  });

  test('die Web-Adresse ist vollständig und aufrufbar geformt', () {
    final uri = Uri.parse(appShareUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, isNotEmpty);
    // Ohne den Pfad landet man auf der GitHub-Seite des Nutzers, nicht auf
    // Root-in — dieselbe Falle wie `--base-href` (Lehre 28).
    expect(uri.path, isNot('/'));
  });

  test('der Play-Link bleibt aus dem Paketnamen abgeleitet', () {
    // Er wird gebraucht, sobald veröffentlicht wird; bis dahin steht er nur
    // bereit. Der Paketname ist nach der Veröffentlichung unveränderlich.
    expect(appPackageName, 'com.rootin.app');
    expect(playStoreUrl, contains(appPackageName));
  });
}
