import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_goal_type.dart';
import 'daos/backup_dao.dart';
import 'daos/category_dao.dart';
import 'daos/habit_completion_dao.dart';
import 'daos/habit_dao.dart';
import 'tables/categories_table.dart';
import 'tables/habit_completions_table.dart';
import 'tables/habits_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Habits, HabitCompletions, Categories],
  daos: [HabitDao, HabitCompletionDao, CategoryDao, BackupDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'root_in_db', web: _webOptions));

  /// Wo die Datenbank im Browser liegt (siehe PLAN.md Phase 26.1).
  ///
  /// Auf Android/iOS ist dieser Wert wirkungslos — dort entscheidet
  /// `drift_flutter` selbst und legt die Datei in
  /// `getApplicationDocumentsDirectory()` ab. Im Browser ist er dagegen
  /// **Pflicht**: `driftDatabase` wirft dort ohne ihn einen `ArgumentError`,
  /// und ohne Datenbank baut keine einzige Seite.
  ///
  /// Beide Dateien liegen neben `index.html` und werden **nicht** versioniert
  /// — `tool/fetch_web_db_assets.sh` holt sie (siehe `web/.gitignore`).
  ///
  /// Drift wählt im Browser selbst zwischen OPFS und IndexedDB, je nachdem,
  /// was der Browser kann. Beides bleibt **auf dem Gerät des Nutzers**:
  /// Abschnitt 3 („kein Backend, keine Konten") gilt im Web unverändert.
  static DriftWebOptions get _webOptions => DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
    driftWorker: Uri.parse('drift_worker.js'),
  );

  /// Für Tests: isolierte Datenbank über einen eigenen [QueryExecutor]
  /// (z. B. In-Memory), damit Tests nie die echte lokale App-Datenbank
  /// lesen/verändern. Siehe `test/support/test_database.dart`.
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // Nur die Tabellen anlegen. Die Standard-Kategorien werden hier bewusst
      // **nicht** eingefügt (bis Phase 11.5 stand hier ein festes
      // „Allgemein"): auf DB-Ebene gibt es noch keine App-Sprache, die Namen
      // wären also immer deutsch. Das Seeding übernimmt
      // `HabitRepository.ensureDefaultCategories` beim App-Start, wo die
      // gewählte Sprache feststeht (siehe main.dart und PLAN.md Phase 21.1).
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Kategorien-Tabelle nachrüsten (siehe PLAN.md Phase 4.5) und aus
        // den bisherigen Freitext-Kategorien der Gewohnheiten befüllen.
        await m.createTable(categories);
        await customStatement(
          'INSERT OR IGNORE INTO categories (name) SELECT DISTINCT category FROM habits',
        );
        // Bleibt bewusst deutsch: dieser Zweig betrifft nur Bestände aus der
        // Zeit vor der Kategorien-Tabelle (Schema 1). Diese Installationen
        // sind deutschsprachig entstanden und haben ihre Kategorie längst;
        // sie nachträglich umzubenennen wäre ein Eingriff in Nutzerdaten.
        await customStatement(
          "INSERT OR IGNORE INTO categories (name) VALUES ('Allgemein')",
        );
      }
      // Schema 3 rüstete die zwei Erinnerungs-Spalten NACH. Mit Phase 28
      // sind sie wieder weg — der Sprung 2 → 4 legt sie deshalb gar nicht
      // erst an, statt sie anzulegen und sofort zu entfernen.
      if (from < 4) {
        // ⚠️ Phase 28: Erinnerungen sind vollständig entfernt (die
        // Web-Fassung kann keinen Wecker stellen). Die beiden Spalten
        // verschwinden damit aus dem Schema.
        //
        // `alterTable` baut die Tabelle neu und überträgt die verbleibenden
        // Spalten — Drifts einziger sicherer Weg, eine Spalte loszuwerden.
        // ⚠️ **Nur die zwei Spalten gehen verloren, sonst nichts:** Die IDs
        // bleiben dieselben, und daran hängt jede Erledigung
        // (`habitId`). Eine Migration, die Gewohnheiten neu anlegt, statt
        // sie zu behalten, würde den ganzen Verlauf von seiner Gewohnheit
        // trennen — genau das prüft `database_migration_test.dart`.
        //
        // ⚠️ Seit Phase 32 kennt die Tabelle eine Spalte mehr
        // (`scheduleDays`). `alterTable` baut nach dem **aktuellen** Schema
        // und liest sonst jede Spalte aus der alten Tabelle — die neue gibt es
        // dort aber nicht. `newColumns` sagt das ausdrücklich; sie bekommt
        // ihren Standardwert („jeden Tag"). Dieser Zweig liefert damit schon
        // den Stand von Schema 5.
        await m.alterTable(
          TableMigration(habits, newColumns: [habits.scheduleDays]),
        );
      } else if (from < 5) {
        // Phase 32: Wochenplan. Bestehende Gewohnheiten bekommen den Standard
        // 127 = jeden Tag — genau das, was sie bisher waren. Nichts wird
        // umgebaut, deshalb bleiben alle IDs unangetastet.
        await m.addColumn(habits, habits.scheduleDays);
      }
    },
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
