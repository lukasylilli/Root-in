import 'package:drift/drift.dart';

/// Vom Nutzer verwaltete Liste möglicher Habit-Kategorien (siehe PLAN.md
/// Abschnitt 5.6/7 — Kategorien sind keine festen Konstanten, sondern frei
/// erstellbar/umbenennbar/löschbar). `Habits.category` referenziert den
/// Namen (nicht die id) — siehe `category_dao.dart` für Umbenennen/Löschen.
@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}
