import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/utils/achievement_evaluator.dart';
import 'package:root_in/data/models/lifetime_stats.dart';

void main() {
  test('keine Achievements ohne jegliche Aktivität', () {
    final unlocked = AchievementEvaluator.unlockedIds(LifetimeStats.empty);
    expect(unlocked, isEmpty);
  });

  test('Streak-Meilensteine schalten sich stufenweise frei', () {
    const stats = LifetimeStats(
      totalPoints: 0,
      totalCompletions: 0,
      longestStreakOverall: 7,
      categoriesUsed: 0,
    );
    final unlocked = AchievementEvaluator.unlockedIds(stats);

    expect(unlocked, containsAll({'streak_3', 'streak_7'}));
    expect(unlocked, isNot(contains('streak_14')));
  });

  test('Punkte- und Kategorie-Achievements werden unabhängig ausgewertet', () {
    const stats = LifetimeStats(
      totalPoints: 1000,
      totalCompletions: 100,
      longestStreakOverall: 0,
      categoriesUsed: 3,
    );
    final unlocked = AchievementEvaluator.unlockedIds(stats);

    expect(
      unlocked,
      containsAll({'points_100', 'points_500', 'points_1000', 'categories_3'}),
    );
    expect(unlocked, isNot(contains('points_5000')));
    expect(unlocked, isNot(contains('categories_5')));
    expect(unlocked, isNot(contains('streak_3')));
  });

  test('exakter Schwellenwert schaltet das Achievement frei (>=)', () {
    const stats = LifetimeStats(
      totalPoints: 100,
      totalCompletions: 10,
      longestStreakOverall: 0,
      categoriesUsed: 0,
    );
    expect(
      AchievementEvaluator.unlockedIds(stats),
      contains('points_100'),
    );
  });
}
