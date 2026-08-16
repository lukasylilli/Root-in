/// Regeln für den **Benutzernamen** (PLAN.md Phase 27.5).
///
/// Bei der Registrierung gibt der Nutzer drei Dinge an: **E-Mail, Passwort
/// und Benutzernamen**. Die ersten beiden verwaltet Supabase in `auth.users`;
/// der Benutzername gehört uns und liegt in `profiles.username`. Er ist der
/// Name, unter dem ein Mensch in der App auftritt — nicht die Kennung, mit
/// der er sich anmeldet.
///
/// **Diese Datei ist die einzige Stelle, an der festgelegt ist, was ein
/// gültiger Benutzername ist.** Zwei Stellen, die unterschiedlich
/// normalisieren, machen die Eindeutigkeit zur Illusion: Der eine Weg legt
/// `Ali` an, der andere sucht `ali` und findet nichts.
///
/// Bewusst **reines Dart ohne Paket-Abhängigkeit** — so ist der Teil, der
/// still falsch sein kann, ohne Server und ohne Netz prüfbar.
///
/// ⚠️ **Die Wahrheit über Eindeutigkeit steht nicht hier, sondern in der
/// Datenbank** (`supabase/schema.sql`, eindeutiger Index auf dem Namen).
/// Diese Datei prüft die *Form*; ob der Name noch frei ist, weiß nur der
/// Server — und zwischen der Frage und dem Absenden kann ihn jemand anders
/// nehmen.
///
/// ⚠️ **Vorgeschichte, damit niemand sie wiederholt:** Bis zum 2026-08-16 hieß
/// diese Datei `username_credentials.dart` und rechnete den Benutzernamen in
/// eine künstliche E-Mail-Adresse um (`ali@rootin.invalid`) — damals sollte
/// die Anmeldung ohne E-Mail auskommen. Mit der Entscheidung für echte
/// Adressen ist dieser Teil **ersatzlos entfallen**; er wäre jetzt toter
/// Code, der eine Absicht vortäuscht, die es nicht mehr gibt.
library;

/// Warum ein Benutzername abgelehnt wurde — **sprachneutral**, wie
/// `BackupFormatException` (Muster aus Phase 9). Die Oberfläche übersetzt;
/// dieser Dienst kennt keine Sprache.
enum UsernameIssue {
  /// Nichts eingegeben.
  empty,

  /// Kürzer als [UsernameRules.minLength].
  tooShort,

  /// Länger als [UsernameRules.maxLength].
  tooLong,

  /// Enthält Zeichen, die nicht erlaubt sind (Leerzeichen, `@`, Punkte …).
  invalidCharacters,
}

abstract final class UsernameRules {
  static const int minLength = 3;
  static const int maxLength = 30;

  /// Erlaubt sind Kleinbuchstaben, Ziffern, `_` und `-`; Anfang und Ende
  /// müssen Buchstabe oder Ziffer sein.
  ///
  /// Bewusst eng: Ein Name, der in Adressen, Dateinamen und geteilten Bildern
  /// auftauchen kann, soll überall dasselbe bedeuten. Sichtbar ähnliche
  /// Zeichen aus verschiedenen Schriftsystemen würden außerdem Namen
  /// erlauben, die für das Auge gleich sind und für die Datenbank nicht —
  /// eine Einladung, sich als jemand anderes auszugeben.
  static final RegExp _allowed = RegExp(r'^[a-z0-9][a-z0-9_-]*[a-z0-9]$');

  /// Vereinheitlicht die Schreibweise: Leerraum weg, klein geschrieben.
  ///
  /// ⚠️ **Immer anwenden — beim Anlegen wie beim Suchen.** Sonst gäbe es
  /// „Ali" und „ali" nebeneinander, und die zugesagte Eindeutigkeit wäre
  /// keine. Der eindeutige Index in der Datenbank rechnet mit demselben
  /// kleingeschriebenen Wert.
  static String normalize(String raw) => raw.trim().toLowerCase();

  /// Prüft den **normalisierten** Namen. `null` heißt: Form in Ordnung.
  ///
  /// Sagt **nichts** darüber, ob der Name noch frei ist — das weiß nur der
  /// Server.
  static UsernameIssue? validate(String raw) {
    final name = normalize(raw);
    if (name.isEmpty) return UsernameIssue.empty;
    if (name.length < minLength) return UsernameIssue.tooShort;
    if (name.length > maxLength) return UsernameIssue.tooLong;
    if (!_allowed.hasMatch(name)) return UsernameIssue.invalidCharacters;
    return null;
  }
}
