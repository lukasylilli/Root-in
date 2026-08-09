import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/categories_table.dart';
import '../tables/habits_table.dart';

part 'category_dao.g.dart';

/// Ergebnis eines Lösch-Versuchs — Kategorien lassen sich nicht löschen,
/// solange eine Gewohnheit sie noch nutzt (siehe PLAN.md Abschnitt 5.6).
enum DeleteCategoryResult { deleted, stillInUse }

/// [DeleteCategoryResult] **mit** der Zahl der blockierenden Gewohnheiten:
/// Der Hinweis an den Nutzer nennt sie (PLAN.md Phase 21.2), und ohne diesen
/// Wert müsste die Oberfläche ein zweites Mal in der Datenbank nachzählen.
/// `habitsUsing` ist bei [DeleteCategoryResult.deleted] immer 0.
typedef DeleteCategoryOutcome = ({DeleteCategoryResult status, int habitsUsing});

@DriftAccessor(tables: [Categories, Habits])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchAllCategories() {
    return (select(categories)..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .watch();
  }

  /// Legt die Kategorie an, falls sie noch nicht existiert (Name-Vergleich).
  /// Wird auch beim Anlegen einer Gewohnheit über eine Vorlage genutzt, um
  /// deren Kategorie ohne separate Verwaltungs-UI verfügbar zu machen.
  Future<void> getOrCreateCategory(String name) async {
    await into(categories).insert(
      CategoriesCompanion.insert(name: name),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Legt [names] als Standard-Kategorien an — aber **nur**, wenn noch gar
  /// keine Kategorie existiert (siehe PLAN.md Phase 11.5 und 21.1). Damit hat
  /// das Gewohnheit-Formular nach einer Neuinstallation sofort eine Auswahl.
  ///
  /// Die Regel „nur wenn die Tabelle leer ist" ist der Kern: Ein späterer
  /// Sprachwechsel darf keinen zweiten Satz hinterherschieben (Nutzerdaten
  /// werden nicht mitübersetzt), und Bestandsnutzer behalten ihre Kategorien
  /// unangetastet. Wer sie nachträglich will, nimmt [addMissingCategories].
  ///
  /// Gibt zurück, wie viele angelegt wurden (0 = es war schon etwas da).
  Future<int> ensureDefaultCategories(List<String> names) async {
    return transaction(() async {
      final existing = await (select(categories)..limit(1)).get();
      if (existing.isNotEmpty) return 0;

      for (final name in names) {
        await into(categories).insert(
          CategoriesCompanion.insert(name: name),
          mode: InsertMode.insertOrIgnore,
        );
      }
      return names.length;
    });
  }

  /// Ergänzt aus [names] nur das, was noch fehlt, und meldet die Anzahl —
  /// der Weg für **Bestandsnutzer** (PLAN.md Phase 21.1, Knopf auf der
  /// Kategorien-Seite). Ohne ihn bekämen bestehende Installationen die
  /// Standard-Kategorien nie zu sehen.
  Future<int> addMissingCategories(List<String> names) async {
    return transaction(() async {
      final existing = {for (final c in await select(categories).get()) c.name};
      final missing = names.where((name) => !existing.contains(name));

      for (final name in missing) {
        await into(categories).insert(
          CategoriesCompanion.insert(name: name),
          mode: InsertMode.insertOrIgnore,
        );
      }
      return missing.length;
    });
  }

  /// Benennt eine Kategorie um und aktualisiert alle Gewohnheiten, die sie
  /// referenzieren, in derselben Transaktion.
  Future<void> renameCategory(int id, String newName) async {
    await transaction(() async {
      final category = await (select(
        categories,
      )..where((c) => c.id.equals(id))).getSingle();

      await (update(categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(name: Value(newName)),
      );
      await (update(habits)..where((h) => h.category.equals(category.name)))
          .write(HabitsCompanion(category: Value(newName)));
    });
  }

  /// Löscht die Kategorie nur, wenn keine Gewohnheit sie mehr referenziert;
  /// im Blockier-Fall kommt deren Anzahl mit zurück (siehe
  /// [DeleteCategoryOutcome]).
  ///
  /// Gilt auch für die Standard-Kategorien aus Phase 21.1 — sie sind
  /// Nutzerdaten, nichts im Code schützt sie.
  Future<DeleteCategoryOutcome> deleteCategory(int id) async {
    return transaction(() async {
      final category = await (select(
        categories,
      )..where((c) => c.id.equals(id))).getSingle();

      final inUse =
          await (select(habits)..where((h) => h.category.equals(category.name)))
              .get();
      if (inUse.isNotEmpty) {
        return (
          status: DeleteCategoryResult.stillInUse,
          habitsUsing: inUse.length,
        );
      }

      await (delete(categories)..where((c) => c.id.equals(id))).go();
      return (status: DeleteCategoryResult.deleted, habitsUsing: 0);
    });
  }
}
