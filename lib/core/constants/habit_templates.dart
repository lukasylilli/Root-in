import 'package:flutter/material.dart';

import '../../data/models/habit_goal_type.dart';
import '../../l10n/gen/app_localizations.dart';
import 'default_categories.dart';

/// Vorlage für schnelles Anlegen einer Gewohnheit.
///
/// Name und Kategorie kommen seit Phase 11 aus [AppLocalizations]. Beim
/// Anlegen wird der Text der **aktuellen** Sprache in die Datenbank
/// geschrieben — die Gewohnheit ist ab dann Nutzerdaten und bleibt bei einem
/// späteren Sprachwechsel bewusst unverändert (sie ist ja frei umbenennbar).
class HabitTemplate {
  const HabitTemplate({
    required this.id,
    required this.categoryId,
    required this.icon,
    required this.goalType,
    this.targetMinutes,
  });

  /// Stabiler, sprachunabhängiger Schlüssel der Vorlage.
  final String id;

  /// [DefaultCategory.id] der Kategorie, in die diese Vorlage gehört (siehe
  /// PLAN.md Phase 21.1). Ein Feld je Vorlage statt einer gemeinsamen
  /// Kategorie für alle elf — die Zuordnung folgt der Anleitung
  /// „Lernplanung"/„Lernquellen".
  final String categoryId;

  final IconData icon;
  final HabitGoalType goalType;
  final int? targetMinutes;

  /// Eine neue Vorlage braucht hier **und** in den ARB-Dateien einen Eintrag;
  /// ohne passenden Fall bliebe sonst die rohe [id] sichtbar.
  String name(AppLocalizations l10n) => switch (id) {
    'youtube' => l10n.templateYoutube,
    'coursebook' => l10n.templateCoursebook,
    'workbook' => l10n.templateWorkbook,
    'words_10min' => l10n.templateWords10Min,
    'words_1hour' => l10n.templateWords1Hour,
    'grammar' => l10n.templateGrammar,
    'writing' => l10n.templateWriting,
    'reading' => l10n.templateReading,
    'speaking' => l10n.templateSpeaking,
    'listening' => l10n.templateListening,
    'memorizing' => l10n.templateMemorizing,
    _ => id,
  };

  /// Name der Kategorie in der aktuellen Sprache. Kommt aus
  /// `default_categories.dart` — dort steht die **eine** Quelle der sieben
  /// Namen, damit eine per Vorlage angelegte Gewohnheit in genau der
  /// Kategorie landet, die beim Erststart schon existiert.
  String category(AppLocalizations l10n) => defaultCategories
      .firstWhere((category) => category.id == categoryId)
      .name(l10n);
}

/// Einzige Quelle für Habit-Vorlagen (siehe PLAN.md Abschnitt 6, Fokus
/// Sprachenlernen). Eigene Habits bleiben über features/habits frei anlegbar.
///
/// [HabitTemplate.categoryId] folgt der Anleitung: Kurs- und Videounterricht
/// (YouTube, Kursbuch, Arbeitsbuch) zählen dort zu **Grammatik** — deshalb
/// keine eigene Kategorie dafür.
const List<HabitTemplate> habitTemplates = [
  HabitTemplate(
    id: 'youtube',
    categoryId: 'grammar',
    icon: Icons.play_circle_outline,
    goalType: HabitGoalType.checkbox,
  ),
  HabitTemplate(
    id: 'coursebook',
    categoryId: 'grammar',
    icon: Icons.menu_book_outlined,
    goalType: HabitGoalType.checkbox,
  ),
  HabitTemplate(
    id: 'workbook',
    categoryId: 'grammar',
    icon: Icons.edit_note_outlined,
    goalType: HabitGoalType.checkbox,
  ),
  HabitTemplate(
    id: 'words_10min',
    categoryId: 'vocabulary',
    icon: Icons.style_outlined,
    goalType: HabitGoalType.duration,
    targetMinutes: 10,
  ),
  HabitTemplate(
    id: 'words_1hour',
    categoryId: 'vocabulary',
    icon: Icons.style_outlined,
    goalType: HabitGoalType.duration,
    targetMinutes: 60,
  ),
  HabitTemplate(
    id: 'grammar',
    categoryId: 'grammar',
    icon: Icons.rule_outlined,
    goalType: HabitGoalType.checkbox,
  ),
  HabitTemplate(
    id: 'writing',
    categoryId: 'writing',
    icon: Icons.create_outlined,
    goalType: HabitGoalType.checkbox,
  ),
  HabitTemplate(
    id: 'reading',
    categoryId: 'reading',
    icon: Icons.chrome_reader_mode_outlined,
    goalType: HabitGoalType.checkbox,
  ),
  HabitTemplate(
    id: 'speaking',
    categoryId: 'speaking',
    icon: Icons.record_voice_over_outlined,
    goalType: HabitGoalType.checkbox,
  ),
  HabitTemplate(
    id: 'listening',
    categoryId: 'listening',
    icon: Icons.headphones_outlined,
    goalType: HabitGoalType.checkbox,
  ),
  HabitTemplate(
    id: 'memorizing',
    categoryId: 'memorization',
    icon: Icons.psychology_outlined,
    goalType: HabitGoalType.checkbox,
  ),
];
