/// Rechnet einen **Benutzernamen** in die Anmeldedaten um, die Supabase
/// erwartet (PLAN.md Phase 27.0b/27.5).
///
/// **Der Nutzer gibt Benutzername und Passwort ein — sonst nichts.** Es gibt
/// kein Eingabefeld für eine E-Mail, es wird keine verschickt, und die
/// Adresse unten bekommt er nie zu sehen. Sie existiert nur, weil die
/// Passwort-Anmeldung von Supabase eine Adresse als Kennung verlangt; für uns
/// ist sie eine interne Schreibweise des Benutzernamens, nicht mehr.
///
/// **Diese Datei ist die einzige Stelle, an der Benutzername und Adresse
/// zusammenhängen.** Verstreut wäre das ein Fehler, den man später nicht mehr
/// einsammeln kann: Zwei Stellen, die unterschiedlich normalisieren, legen
/// stillschweigend zwei Konten für denselben Menschen an.
///
/// Bewusst **reines Dart ohne Paket-Abhängigkeit**: `auth_service.dart` ist
/// der einzige Aufrufer, aber der Teil, der still falsch sein kann, ist
/// dieser hier — und er lässt sich so ohne Server und ohne Netz prüfen.
///
/// ⚠️ **Zwei Dinge fallen mit dieser Wahl weg:** ein Zurücksetzen des
/// Passworts (es gibt keine Adresse, an die ein Link gehen könnte) und jede
/// Mail-Grenze des kostenlosen Tarifs. Das erste ist der Preis, das zweite
/// der Gewinn. Weil die App lokal zuerst arbeitet, kostet ein vergessenes
/// Passwort die **Kopie auf dem Server**, nicht die Daten auf dem Gerät.
library;

/// Warum ein Benutzername abgelehnt wurde — **sprachneutral**, wie
/// `BackupFormatException` (Muster aus Phase 9). Die Oberfläche übersetzt;
/// dieser Dienst kennt keine Sprache.
enum UsernameIssue {
  /// Nichts eingegeben.
  empty,

  /// Kürzer als [UsernameCredentials.minLength].
  tooShort,

  /// Länger als [UsernameCredentials.maxLength].
  tooLong,

  /// Enthält Zeichen, die nicht erlaubt sind (Leerzeichen, `@`, Punkte …).
  invalidCharacters,
}

abstract final class UsernameCredentials {
  /// Domain der internen Adresse.
  ///
  /// `.invalid` ist per RFC 2606 **dauerhaft für genau solche Zwecke
  /// reserviert** und kann nie jemandem gehören. Eine echte Domain hätte hier
  /// ein reales Risiko: Landet eine Nachricht doch einmal im Versand, ginge
  /// sie an einen fremden, existierenden Posteingang.
  ///
  /// ⚠️ Steht bewusst als **eine** Konstante da. Sollte Supabase diese Endung
  /// ablehnen (bei 27.2 zu prüfen), ist der Wechsel eine Zeile — aber er
  /// **verwaist alle bestehenden Konten**, weil sie unter der alten Adresse
  /// angelegt wurden. Also vor dem ersten echten Nutzer prüfen, nicht danach.
  static const String domain = 'rootin.invalid';

  static const int minLength = 3;
  static const int maxLength = 30;

  /// Erlaubt sind Kleinbuchstaben, Ziffern, `_` und `-`; Anfang und Ende
  /// müssen Buchstabe oder Ziffer sein.
  ///
  /// Die Einschränkung ist keine Willkür: Der Name wird Teil einer Adresse.
  /// Ein `@` oder ein Leerzeichen darin ergäbe eine ungültige Adresse, und
  /// die Anmeldung scheiterte mit einer Server-Meldung, die kein Nutzer
  /// verstehen kann.
  static final RegExp _allowed = RegExp(r'^[a-z0-9][a-z0-9_-]*[a-z0-9]$');

  /// Vereinheitlicht die Schreibweise: Leerraum weg, klein geschrieben.
  ///
  /// ⚠️ **Ohne diesen Schritt wären „Ali" und „ali" zwei Konten** — und der
  /// Nutzer suchte seinen Bestand im falschen, ohne zu verstehen, warum er
  /// leer ist. Deshalb wird **immer** normalisiert, bei Registrierung wie bei
  /// Anmeldung, und nie nur an einer der beiden Stellen.
  static String normalize(String raw) => raw.trim().toLowerCase();

  /// Prüft den **normalisierten** Namen. `null` heißt: in Ordnung.
  static UsernameIssue? validate(String raw) {
    final name = normalize(raw);
    if (name.isEmpty) return UsernameIssue.empty;
    if (name.length < minLength) return UsernameIssue.tooShort;
    if (name.length > maxLength) return UsernameIssue.tooLong;
    if (!_allowed.hasMatch(name)) return UsernameIssue.invalidCharacters;
    return null;
  }

  /// Interne Adresse zu einem Benutzernamen.
  ///
  /// Wirft [ArgumentError], wenn der Name ungültig ist — geprüft wird
  /// **vorher** in der Oberfläche mit [validate]. Ein ungültiger Name kommt
  /// hier nicht mehr an; käme er doch, ist das ein Programmierfehler und
  /// kein Nutzerfehler, und dann ist ein Absturz im Test ehrlicher als eine
  /// kaputte Adresse im Betrieb.
  static String emailFor(String rawUsername) {
    final issue = validate(rawUsername);
    if (issue != null) {
      throw ArgumentError.value(rawUsername, 'rawUsername', 'ungültig: $issue');
    }
    return '${normalize(rawUsername)}@$domain';
  }

  /// Der Benutzername zu einer internen Adresse — für die Anzeige
  /// („angemeldet als …"). `null`, wenn die Adresse nicht von uns stammt.
  ///
  /// Der Rückweg ist nötig, weil Supabase nach der Anmeldung die **Adresse**
  /// zurückgibt. Ohne ihn stünde in der App `ali@rootin.invalid` — eine
  /// Zeichenfolge, die der Nutzer nie eingegeben hat und nicht deuten kann.
  static String? usernameFrom(String? email) {
    if (email == null) return null;
    final suffix = '@$domain';
    if (!email.toLowerCase().endsWith(suffix)) return null;
    final name = email.substring(0, email.length - suffix.length);
    return name.isEmpty ? null : name.toLowerCase();
  }
}
