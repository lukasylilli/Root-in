import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:root_in/data/local/database.dart';

/// Einzige Quelle für eine isolierte Test-Datenbank. Jeder Widget-Test, der
/// DB-gestützte Provider berührt, überschreibt `appDatabaseProvider` mit
/// dem Ergebnis dieser Funktion — nie mit der echten App-Datenbank, damit
/// Tests sich nicht gegenseitig beeinflussen oder reale Nutzerdaten
/// verändern. Jeder Aufruf liefert eine eigene, komplett isolierte
/// In-Memory-Instanz (kein gemeinsamer Executor) — Drifts globale
/// „mehrfach geöffnet"-Warnung ist dafür bewusst deaktiviert.
AppDatabase createTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase.forTesting(NativeDatabase.memory());
}
