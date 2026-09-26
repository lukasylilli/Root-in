/// Einmalige Übernahme der alten Einträge `flutter.…` in Root-ins eigenen
/// Namensraum (PLAN.md 31.8) — siehe `root_in_preferences.dart`.
///
/// Nur im Browser gibt es etwas zu übernehmen; außerhalb (die Tests auf der
/// Dart-VM) tut die Funktion nichts.
library;

export 'legacy_preferences_migration_io.dart'
    if (dart.library.js_interop) 'legacy_preferences_migration_web.dart';
