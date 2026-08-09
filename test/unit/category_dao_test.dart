import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/data/local/daos/category_dao.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('getOrCreateCategory legt Kategorie an, dupliziert nicht', () async {
    await db.categoryDao.getOrCreateCategory('Sport');
    await db.categoryDao.getOrCreateCategory('Sport');

    final all = await db.categoryDao.watchAllCategories().first;
    // Die Test-DB startet leer (die Standard-Kategorien legt erst der
    // App-Start an) — 'Sport' darf trotz zweifachem Aufruf nur einmal da sein.
    expect(all.where((c) => c.name == 'Sport'), hasLength(1));
  });

  test('renameCategory aktualisiert auch zugeordnete Gewohnheiten', () async {
    await db.categoryDao.getOrCreateCategory('Sport');
    final categories = await db.categoryDao.watchAllCategories().first;
    final category = categories.firstWhere((c) => c.name == 'Sport');

    final habitId = await db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: 'Laufen',
        colorValue: 0xFF000000,
        category: const Value('Sport'),
        goalType: HabitGoalType.checkbox,
      ),
    );

    await db.categoryDao.renameCategory(category.id, 'Fitness');

    final renamedNames = (await db.categoryDao.watchAllCategories().first)
        .map((c) => c.name);
    expect(renamedNames, contains('Fitness'));
    expect(renamedNames, isNot(contains('Sport')));

    final habit = await db.habitDao.habitById(habitId);
    expect(habit!.category, 'Fitness');
  });

  test('deleteCategory schlägt fehl, solange eine Gewohnheit sie nutzt', () async {
    await db.categoryDao.getOrCreateCategory('Sport');
    final categories = await db.categoryDao.watchAllCategories().first;
    final category = categories.firstWhere((c) => c.name == 'Sport');

    await db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: 'Laufen',
        colorValue: 0xFF000000,
        category: const Value('Sport'),
        goalType: HabitGoalType.checkbox,
      ),
    );

    final result = await db.categoryDao.deleteCategory(category.id);

    expect(result.status, DeleteCategoryResult.stillInUse);
    // Phase 21.2: Der Hinweis nennt, wie viele Gewohnheiten noch blockieren.
    expect(result.habitsUsing, 1);
    expect(await db.categoryDao.watchAllCategories().first, isNotEmpty);
  });

  test('deleteCategory löscht, wenn keine Gewohnheit sie mehr nutzt', () async {
    await db.categoryDao.getOrCreateCategory('Sport');
    final all = await db.categoryDao.watchAllCategories().first;
    final category = all.firstWhere((c) => c.name == 'Sport');

    final result = await db.categoryDao.deleteCategory(category.id);

    expect(result.status, DeleteCategoryResult.deleted);
    expect(result.habitsUsing, 0);
    final remaining = await db.categoryDao.watchAllCategories().first;
    expect(remaining.map((c) => c.name), isNot(contains('Sport')));
  });

  // Phase 11.5: Die Kategorien entstehen nicht in der Migration, sondern beim
  // App-Start in der gewählten Sprache. Phase 21.1: statt einer sind es die
  // sieben Fertigkeiten aus der Anleitung.
  const defaults = [
    'Grammatik',
    'Wortschatz',
    'Auswendiglernen',
    'Lesen',
    'Schreiben',
    'Sprechen',
    'Hören',
  ];

  test('Erststart legt genau die sieben Standard-Kategorien an', () async {
    expect(await db.categoryDao.watchAllCategories().first, isEmpty);

    final created = await db.categoryDao.ensureDefaultCategories(defaults);

    expect(created, 7);
    final all = await db.categoryDao.watchAllCategories().first;
    expect(all, hasLength(7));
    expect(all.map((c) => c.name), containsAll(defaults));
  });

  test('zweiter Start legt nichts nach', () async {
    await db.categoryDao.ensureDefaultCategories(defaults);

    final created = await db.categoryDao.ensureDefaultCategories(defaults);

    expect(created, 0);
    expect(await db.categoryDao.watchAllCategories().first, hasLength(7));
  });

  test('Sprachwechsel legt keinen zweiten Satz nach', () async {
    // Der Kern der Regel „nur wenn die Tabelle leer ist" (Phase 11.5):
    // Nutzerdaten werden nicht mitübersetzt, also darf ein Wechsel auf
    // Englisch die deutschen Kategorien weder ersetzen noch ergänzen.
    await db.categoryDao.ensureDefaultCategories(defaults);

    final created = await db.categoryDao.ensureDefaultCategories([
      'Grammar',
      'Vocabulary',
      'Memorization',
      'Reading',
      'Writing',
      'Speaking',
      'Listening',
    ]);

    expect(created, 0);
    final all = await db.categoryDao.watchAllCategories().first;
    expect(all, hasLength(7));
    expect(all.map((c) => c.name), containsAll(defaults));
  });

  test('Nachrüst-Knopf ergänzt nur Fehlendes', () async {
    // Bestandsnutzer: eigene Kategorie plus zwei, die auch Standard sind.
    await db.categoryDao.getOrCreateCategory('Sport');
    await db.categoryDao.getOrCreateCategory('Lesen');
    await db.categoryDao.getOrCreateCategory('Schreiben');

    final added = await db.categoryDao.addMissingCategories(defaults);

    expect(added, 5);
    final all = await db.categoryDao.watchAllCategories().first;
    // Die eigene bleibt, die vorhandenen werden nicht dupliziert.
    expect(all, hasLength(8));
    expect(all.map((c) => c.name), contains('Sport'));
    expect(all.where((c) => c.name == 'Lesen'), hasLength(1));
  });

  test('Nachrüst-Knopf meldet 0, wenn alle sieben schon da sind', () async {
    await db.categoryDao.ensureDefaultCategories(defaults);

    expect(await db.categoryDao.addMissingCategories(defaults), 0);
    expect(await db.categoryDao.watchAllCategories().first, hasLength(7));
  });
}
