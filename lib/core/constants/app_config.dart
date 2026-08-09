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
/// Root-in hat heute **keine** Geheimnisse: kein Backend, keine Konten, die
/// Werbung ist seit Phase 20 stillgelegt. Diese Datei existiert trotzdem,
/// damit ein späterer Server-Anteil nicht improvisiert werden muss — und
/// damit die Warnung oben an der Stelle steht, an der jemand den ersten
/// Schlüssel eintragen würde.
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
}
