// `hide isNull`: Drift bringt einen gleichnamigen SQL-Ausdruck mit, hier ist
// aber der Matcher von flutter_test gemeint.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:sqlite3/sqlite3.dart';

/// **Der eigentliche Gegenstand von PLAN.md Phase 25.**
///
/// Ein App-Update löscht auf Android nichts: Die Datei liegt über
/// `drift_flutter` in `getApplicationDocumentsDirectory()`, und die räumt das
/// System bei einem Update nicht auf. Die reale Gefahr ist eine andere — eine
/// erhöhte `schemaVersion` **ohne** passenden `onUpgrade`-Zweig. Drift öffnet
/// die alte Datei dann nicht mehr; die App startet nach dem Update nicht, und
/// für den Nutzer ist das von „alles weg" nicht zu unterscheiden.
///
/// Diese Tests ziehen deshalb echte Bestände aus Schema 1 und 2 hoch und
/// prüfen, dass **jede Zeile mit ihrer ID** überlebt. Die IDs sind der Punkt:
/// `HabitCompletions.habitId` verweist darauf, und eine Migration, die
/// Gewohnheiten neu anlegt statt sie zu behalten, würde jede Erledigung von
/// ihrer Gewohnheit trennen.
///
/// **Aufbau:** Statt das alte Schema von Hand zu tippen (und dabei vom
/// echten abzuweichen), lässt der Test Drift den **aktuellen** Stand anlegen
/// und baut ihn dann gezielt zurück — Spalten weg, Tabelle weg,
/// `user_version` zurück. Was dabei entsteht, ist per Konstruktion genau das,
/// was frühere App-Versionen auf dem Gerät hinterlassen haben.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// Legt eine Datenbank im aktuellen Schema an und gibt den rohen
  /// sqlite3-Griff zurück. `closeUnderlyingOnClose: false` ist wichtig — sonst
  /// nimmt Drift beim Schließen die In-Memory-Datei mit, und der Rückbau
  /// liefe ins Leere.
  Future<Database> freshCurrentSchema() async {
    final raw = sqlite3.openInMemory();
    final db = AppDatabase.forTesting(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    // Irgendeine Abfrage zwingt Drift, die Tabellen wirklich anzulegen.
    await db.customSelect('SELECT 1').get();
    await db.close();
    return raw;
  }

  /// Baut [raw] auf Schema [version] zurück (1 oder 2) und trägt einen
  /// Bestand ein, wie ihn eine App dieser Fassung hinterlassen hätte.
  void downgradeTo(Database raw, int version) {
    if (version < 3) {
      // Phase 7 hat diese beiden Spalten gebracht.
      raw.execute('ALTER TABLE habits DROP COLUMN reminder_enabled;');
      raw.execute('ALTER TABLE habits DROP COLUMN reminder_minute_of_day;');
    }
    if (version < 2) {
      // Phase 4.5 hat die Kategorien-Tabelle gebracht.
      raw.execute('DROP TABLE categories;');
    }
    raw.execute('PRAGMA user_version = $version;');
  }

  /// Zwei Gewohnheiten und drei Erledigungen — mit **festen IDs**, damit der
  /// Test hinterher nicht nur zählen, sondern zuordnen kann.
  void seedOldData(Database raw) {
    raw.execute('''
      INSERT INTO habits (id, name, icon_key, color_value, category, goal_type,
                          target_minutes, times_per_week, start_date, created_at, archived)
      VALUES
        (7,  'Lesen',  'task_alt', 4278190080, 'Sprachenlernen', 0, NULL, 7, 0, 0, 0),
        (42, 'Laufen', 'task_alt', 4278190080, 'Sport',          1, 30,   3, 0, 0, 1);
    ''');
    raw.execute('''
      INSERT INTO habit_completions (id, habit_id, date, value_minutes, completed_at)
      VALUES
        (1, 7,  1700000000, NULL, 1700000000),
        (2, 7,  1700086400, NULL, 1700086400),
        (3, 42, 1700000000, 30,   1700000000);
    ''');
  }

  /// Öffnet [raw] als App-Datenbank — dabei läuft die Migration.
  AppDatabase reopen(Database raw) =>
      AppDatabase.forTesting(NativeDatabase.opened(raw));

  Future<void> expectDataSurvived(AppDatabase db) async {
    final habits = await db.habitDao.select(db.habits).get();
    expect(habits, hasLength(2));

    final lesen = habits.firstWhere((h) => h.id == 7);
    expect(lesen.name, 'Lesen');
    expect(lesen.category, 'Sprachenlernen');
    expect(lesen.goalType, HabitGoalType.checkbox);
    expect(lesen.timesPerWeek, 7);
    expect(lesen.archived, isFalse);

    final laufen = habits.firstWhere((h) => h.id == 42);
    expect(laufen.name, 'Laufen');
    expect(laufen.targetMinutes, 30);
    // Archivierte Gewohnheiten dürfen nicht unter den Tisch fallen — an
    // ihnen hängen die Erledigungen vergangener Wochen.
    expect(laufen.archived, isTrue);

    final completions = await db.habitCompletionDao
        .select(db.habitCompletions)
        .get();
    expect(completions, hasLength(3));
    // Der eigentliche Prüfpunkt: Die Verweise zeigen noch auf dieselben IDs.
    expect(completions.where((c) => c.habitId == 7), hasLength(2));
    expect(completions.firstWhere((c) => c.habitId == 42).valueMinutes, 30);
  }

  test('Schema 1 → aktuell: Bestand bleibt vollständig erhalten', () async {
    final raw = await freshCurrentSchema();
    downgradeTo(raw, 1);
    seedOldData(raw);

    final db = reopen(raw);
    addTearDown(db.close);

    await expectDataSurvived(db);

    // Die Migration 1→2 legt die Kategorien-Tabelle an und füllt sie aus den
    // Freitext-Kategorien der Gewohnheiten — sonst stünde die Kategorien-
    // Verwaltung nach dem Update leer da.
    final categories = await db.categoryDao.watchAllCategories().first;
    expect(
      categories.map((c) => c.name),
      containsAll(<String>['Sprachenlernen', 'Sport']),
    );

    // Die Migration 2→3 hat die Erinnerungs-Spalten nachgerüstet; ohne sie
    // würde jede Abfrage auf `habits` nach dem Update werfen.
    final habit = await db.habitDao.habitById(7);
    expect(habit!.reminderEnabled, isFalse);
    expect(habit.reminderMinuteOfDay, isNull);
  });

  test('Schema 2 → aktuell: Bestand und Kategorien bleiben erhalten', () async {
    final raw = await freshCurrentSchema();
    downgradeTo(raw, 2);
    seedOldData(raw);
    // Ab Schema 2 gibt es die Tabelle — mit einer Kategorie, die KEINE
    // Gewohnheit nutzt. Auch die ist Nutzerdatum und muss überleben.
    raw.execute("INSERT INTO categories (id, name) VALUES (1, 'Achtsamkeit');");

    final db = reopen(raw);
    addTearDown(db.close);

    await expectDataSurvived(db);

    final categories = await db.categoryDao.watchAllCategories().first;
    expect(categories.map((c) => c.name), contains('Achtsamkeit'));

    final habit = await db.habitDao.habitById(42);
    expect(habit!.reminderEnabled, isFalse);
  });

  test('aktuelles Schema öffnet sich ohne Migration', () async {
    // Der Normalfall jedes Updates ohne Schema-Änderung: Die Datei ist schon
    // aktuell, es darf trotzdem nichts angefasst werden.
    final raw = await freshCurrentSchema();
    seedOldData(raw);

    final db = reopen(raw);
    addTearDown(db.close);

    await expectDataSurvived(db);
    expect(raw.select('PRAGMA user_version;').first.values.first, 3);
  });

  test('schemaVersion und onUpgrade-Zweige passen zusammen', () {
    // Wächst `schemaVersion`, ohne dass jemand einen Zweig ergänzt, schlägt
    // dieser Test fehl statt erst das Gerät eines Nutzers (PLAN.md
    // Abschnitt 9, „Datenerhalt geht vor"). Die Zahl hier ist bewusst von
    // Hand gepflegt: Sie ist die Zusage, dass die Migration mitgewachsen ist.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(
      db.schemaVersion,
      3,
      reason:
          'schemaVersion wurde erhöht. Ergänze in database.dart einen '
          'onUpgrade-Zweig, erweitere die Tests oben um das neue Schema und '
          'passe diese Zahl an.',
    );
  });
}
