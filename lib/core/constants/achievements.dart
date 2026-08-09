import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

/// Woran ein Achievement gemessen wird — siehe `LifetimeStats` für die
/// jeweilige Kennzahl.
enum AchievementMetric { streak, points, categories }

/// Ein einzelnes, vordefiniertes Achievement. Freigeschaltet, sobald die
/// zugehörige Kennzahl aus `LifetimeStats` [threshold] erreicht.
///
/// Titel und Beschreibung sind seit Phase 11 keine Felder mehr, sondern
/// kommen aus [AppLocalizations]: die Definitionsliste bleibt `const` und
/// sprachneutral, die Anzeige folgt der gewählten App-Sprache.
class Achievement {
  const Achievement({
    required this.id,
    required this.icon,
    required this.metric,
    required this.threshold,
  });

  /// Stabiler, sprachunabhängiger Schlüssel — Freischalt-Logik und UI
  /// referenzieren Achievements ausschließlich hierüber.
  final String id;
  final IconData icon;
  final AchievementMetric metric;
  final int threshold;

  /// Ein neues Achievement braucht hier **und** in den ARB-Dateien einen
  /// Eintrag; ohne passenden Fall bliebe sonst die rohe [id] sichtbar.
  String title(AppLocalizations l10n) => switch (id) {
    'streak_3' => l10n.achievementStreak3Title,
    'streak_7' => l10n.achievementStreak7Title,
    'streak_14' => l10n.achievementStreak14Title,
    'streak_30' => l10n.achievementStreak30Title,
    'streak_100' => l10n.achievementStreak100Title,
    'points_100' => l10n.achievementPoints100Title,
    'points_500' => l10n.achievementPoints500Title,
    'points_1000' => l10n.achievementPoints1000Title,
    'points_5000' => l10n.achievementPoints5000Title,
    'categories_3' => l10n.achievementCategories3Title,
    'categories_5' => l10n.achievementCategories5Title,
    _ => id,
  };

  /// Die Beschreibung folgt direkt aus Kennzahl + Schwelle — drei Textmuster
  /// genügen für alle Achievements, statt elf einzelne Sätze zu pflegen.
  String description(AppLocalizations l10n) => switch (metric) {
    AchievementMetric.streak => l10n.achievementStreakDescription(threshold),
    AchievementMetric.points => l10n.achievementPointsDescription(threshold),
    AchievementMetric.categories => l10n.achievementCategoriesDescription(
      threshold,
    ),
  };
}

/// Einzige Quelle für Achievement-Definitionen (siehe PLAN.md Abschnitt 7).
/// Freischalt-Logik lebt separat in `core/utils/achievement_evaluator.dart`.
const List<Achievement> achievements = [
  Achievement(
    id: 'streak_3',
    icon: Icons.local_fire_department_outlined,
    metric: AchievementMetric.streak,
    threshold: 3,
  ),
  Achievement(
    id: 'streak_7',
    icon: Icons.local_fire_department_outlined,
    metric: AchievementMetric.streak,
    threshold: 7,
  ),
  Achievement(
    id: 'streak_14',
    icon: Icons.local_fire_department,
    metric: AchievementMetric.streak,
    threshold: 14,
  ),
  Achievement(
    id: 'streak_30',
    icon: Icons.local_fire_department,
    metric: AchievementMetric.streak,
    threshold: 30,
  ),
  Achievement(
    id: 'streak_100',
    icon: Icons.whatshot,
    metric: AchievementMetric.streak,
    threshold: 100,
  ),
  Achievement(
    id: 'points_100',
    icon: Icons.stars_outlined,
    metric: AchievementMetric.points,
    threshold: 100,
  ),
  Achievement(
    id: 'points_500',
    icon: Icons.stars_outlined,
    metric: AchievementMetric.points,
    threshold: 500,
  ),
  Achievement(
    id: 'points_1000',
    icon: Icons.stars,
    metric: AchievementMetric.points,
    threshold: 1000,
  ),
  Achievement(
    id: 'points_5000',
    icon: Icons.stars,
    metric: AchievementMetric.points,
    threshold: 5000,
  ),
  Achievement(
    id: 'categories_3',
    icon: Icons.category_outlined,
    metric: AchievementMetric.categories,
    threshold: 3,
  ),
  Achievement(
    id: 'categories_5',
    icon: Icons.category,
    metric: AchievementMetric.categories,
    threshold: 5,
  ),
];
