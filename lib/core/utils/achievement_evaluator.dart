import '../../data/models/lifetime_stats.dart';
import '../constants/achievements.dart';

/// Reine Freischalt-Logik ohne Datenbankzugriff (gut testbar, Muster wie
/// `streak_calculator.dart`). Vergleicht [LifetimeStats] gegen die
/// Achievement-Schwellenwerte aus `core/constants/achievements.dart`.
abstract final class AchievementEvaluator {
  static Set<String> unlockedIds(LifetimeStats stats) {
    return {
      for (final achievement in achievements)
        if (_valueFor(achievement.metric, stats) >= achievement.threshold)
          achievement.id,
    };
  }

  static int _valueFor(AchievementMetric metric, LifetimeStats stats) {
    switch (metric) {
      case AchievementMetric.streak:
        return stats.longestStreakOverall;
      case AchievementMetric.points:
        return stats.totalPoints;
      case AchievementMetric.categories:
        return stats.categoriesUsed;
    }
  }
}
