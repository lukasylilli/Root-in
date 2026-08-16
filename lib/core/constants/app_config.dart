/// Einzige Stelle für Werte, die **beim Bauen** hereingereicht werden
/// (`--dart-define`), statt im Code zu stehen — siehe PLAN.md Phase 26.5/26.6.
///
/// ⚠️ **Ein `--dart-define` ist keine Verschlüsselung.** Der Wert wird in das
/// Bundle einkompiliert und lässt sich dort finden — im Web mit einer
/// Textsuche in `main.dart.js`, auf Android mit etwas mehr Mühe. Was er
/// leistet: Der Wert steht nicht im Repository und lässt sich je Umgebung
/// austauschen. Was er **nicht** leistet: ihn vor dem Nutzer verbergen.
///
/// Daraus folgt die Regel, an der sich jeder künftige Schlüssel messen lassen
/// muss: **Was geheim bleiben muss, gehört nicht in die App, sondern hinter
/// einen Server, der es nie herausgibt.** Ein API-Schlüssel, den die App
/// mitschickt, ist ein veröffentlichter API-Schlüssel.
///
/// **Seit Phase 27 gibt es den ersten Schlüssel** — und er ist genau der
/// Sonderfall, für den die Regel oben nicht gilt: Der `anon`-Schlüssel von
/// Supabase ist **dafür gemacht**, in Clients zu stehen. Er ist kein
/// Geheimnis, sondern eine Kennung. Was fremde Zugriffe abwehrt, sind
/// ausschließlich die Zugriffsregeln der Datenbank (`supabase/schema.sql`).
///
/// ⚠️ **Der `service_role`-Schlüssel ist das Gegenteil davon.** Er umgeht
/// jede dieser Regeln. Er gehört nie in diese Datei, nie in ein
/// `--dart-define`, nie in das Repository — das öffentlich ist.
abstract final class AppConfig {
  /// Versionsname, beim Bauen aus `pubspec.yaml` übernommen
  /// (siehe `tool/build_web.sh`) — damit die Version **eine** Quelle behält.
  ///
  /// `dev` bedeutet: aus der Entwicklungsumgebung gestartet, nicht gebaut.
  static const String versionName = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: 'dev',
  );

  /// Laufende Nummer des Baus. In der Automatik die Lauf-Nummer von GitHub
  /// Actions, lokal `0`. Sie beantwortet die Frage „welchen Stand sieht der
  /// Nutzer gerade?" — bei einer Web-Fassung, die sich unbemerkt
  /// aktualisiert, ist das der einzige verlässliche Anhaltspunkt.
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '0',
  );

  /// Anzeigefertige Fassung, z. B. `1.0.0+42`.
  static String get fullVersion => '$versionName+$buildNumber';

  // --------------------------------------------------------------------
  // Supabase (PLAN.md Phase 27)
  // --------------------------------------------------------------------

  /// Adresse des Supabase-Projekts, z. B. `https://<kennung>.supabase.co`.
  ///
  /// **Leer bedeutet: kein Server.** Dann gibt es keine Anmeldung, keine
  /// Cloud-Sicherung und keinen einzigen Netzaufruf dorthin — die App
  /// verhält sich exakt wie vor Phase 27. Abgefragt wird das nicht hier,
  /// sondern über `supportsCloudSync` in `core/utils/platform_support.dart`.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Öffentlicher `anon`-Schlüssel des Projekts.
  ///
  /// ⚠️ **Kein Geheimnis, und das ist Absicht.** Er steht im ausgelieferten
  /// Bundle und lässt sich dort finden (Lehre 26). Er sagt dem Server nur,
  /// *welches Projekt* gemeint ist; *welche Zeilen* jemand sehen darf,
  /// entscheiden die Regeln in `supabase/schema.sql` anhand des
  /// Anmelde-Tokens. Wer diesen Schlüssel kopiert, bekommt damit **keinen**
  /// Zugriff auf fremde Daten — vorausgesetzt, die Regeln stimmen. Sie sind
  /// die einzige Verteidigung; es gibt keine zweite.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Ob beide Supabase-Werte gesetzt sind.
  ///
  /// Bewusst hier und nicht bei den Fähigkeiten: Diese Datei weiß, was
  /// hereingereicht wurde. `platform_support.dart` baut darauf die Frage
  /// auf, die der Aufrufer wirklich stellt („gibt es hier eine Cloud?").
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
