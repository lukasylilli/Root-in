import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/theme/app_theme_variant.dart';
import 'package:root_in/core/widgets/chart_card.dart';
import 'package:root_in/data/models/category_breakdown.dart';
import 'package:root_in/data/models/habit_period_stats.dart';
import 'package:root_in/features/view/overview/overview_board.dart';
import 'package:root_in/features/view/overview/overview_metrics.dart';

import '../support/localized_app.dart';

/// Montag der ersten der vier Wochen.
final _start = DateTime(2026, 7, 6);

/// Mitten in der vierten Woche — danach beginnen die „noch offenen" Tage.
final _today = DateTime(2026, 7, 30);

const _stats = [
  HabitPeriodStats(
    habitId: 1,
    name: 'Lesen',
    category: 'Kopf',
    doneCount: 20,
    targetCount: 28,
    currentStreak: 5,
    longestStreak: 11,
  ),
  HabitPeriodStats(
    habitId: 2,
    name: 'Laufen',
    category: 'Sport',
    doneCount: 6,
    targetCount: 12,
    currentStreak: 2,
    longestStreak: 4,
  ),
];

Widget _board() {
  return localizedApp(
    Scaffold(
      body: OverviewBoard(
        start: _start,
        today: _today,
        stats: _stats,
        doneDays: {
          1: {DateTime(2026, 7, 6), DateTime(2026, 7, 9)},
          2: {DateTime(2026, 7, 9)},
        },
        dailyCounts: {DateTime(2026, 7, 6): 1, DateTime(2026, 7, 9): 2},
        weekCategories: const [
          [
            CategoryBreakdown(category: 'Kopf', count: 5),
            CategoryBreakdown(category: 'Sport', count: 2),
          ],
          [CategoryBreakdown(category: 'Kopf', count: 4)],
          [],
          [CategoryBreakdown(category: 'Sport', count: 3)],
        ],
        tokens: AppThemeVariant.green.tokens(Brightness.light),
      ),
    ),
  );
}

Finder _cell(int habitId, DateTime day) =>
    find.byKey(ValueKey('cell-$habitId-${day.toIso8601String()}'));

void main() {
  testWidgets('Board hat 28 Spalten je Gewohnheit, beginnend am Montag', (
    tester,
  ) async {
    await tester.pumpWidget(_board());

    expect(_cell(1, _start), findsOneWidget);
    expect(_cell(1, DateTime(2026, 8, 2)), findsOneWidget); // Tag 28
    expect(_cell(1, DateTime(2026, 8, 3)), findsNothing); // Tag 29
    expect(_cell(2, DateTime(2026, 7, 5)), findsNothing); // Tag vor dem Start

    expect(tester.takeException(), isNull);
  });

  testWidgets('Tage stehen in allen Zeilen in derselben Spalte', (
    tester,
  ) async {
    // Kern der Seite (siehe OverviewMetrics): egal welche Zeile, ein Tag liegt
    // immer an derselben x-Position — sonst zeigt die Matrix andere Tage als
    // die Diagramme darüber.
    await tester.pumpWidget(_board());

    for (final day in [_start, DateTime(2026, 7, 9), DateTime(2026, 8, 2)]) {
      expect(
        tester.getTopLeft(_cell(1, day)).dx,
        tester.getTopLeft(_cell(2, day)).dx,
        reason: 'Spalte von $day verschiebt sich zwischen zwei Zeilen',
      );
    }

    // Aufeinanderfolgende Tage liegen genau eine Spaltenbreite auseinander.
    expect(
      tester.getTopLeft(_cell(1, DateTime(2026, 7, 7))).dx -
          tester.getTopLeft(_cell(1, _start)).dx,
      moreOrLessEquals(OverviewMetrics.dayWidth, epsilon: 0.01),
    );
  });

  testWidgets('Tabellen-Zeile liegt auf Höhe ihrer Matrix-Zeile', (
    tester,
  ) async {
    await tester.pumpWidget(_board());

    // Erste Zeile: Matrix-Zelle und die Werte rechts (erledigt 20, offen 8,
    // aktuelle Serie 5, längste 11) stehen auf derselben Höhe.
    final rowTop = tester.getTopLeft(_cell(1, _start)).dy;
    for (final value in ['20', '8', '5', '11']) {
      expect(
        tester.getTopLeft(find.text(value)).dy,
        moreOrLessEquals(rowTop, epsilon: OverviewMetrics.rowHeight),
        reason: 'Wert $value steht nicht auf Höhe seiner Matrix-Zeile',
      );
    }

    // Zweite Zeile liegt genau eine Zeilenhöhe tiefer.
    expect(
      tester.getTopLeft(_cell(2, _start)).dy - rowTop,
      moreOrLessEquals(OverviewMetrics.rowHeight, epsilon: 0.01),
    );
  });

  testWidgets('Jede Woche hat genau einen Kreis, mittig unter ihrer Spalte', (
    tester,
  ) async {
    await tester.pumpWidget(_board());

    final pies = find.byType(CategoryPieChart);
    expect(pies, findsNWidgets(OverviewMetrics.weekCount));

    final boardLeft = tester.getTopLeft(find.byType(OverviewBoard)).dx;
    for (var week = 0; week < OverviewMetrics.weekCount; week++) {
      final expectedCenter =
          boardLeft +
          OverviewMetrics.weekLeft(week) +
          OverviewMetrics.weekWidth / 2;
      expect(
        tester.getCenter(pies.at(week)).dx,
        moreOrLessEquals(expectedCenter, epsilon: 0.01),
        reason: 'Kreis von Woche ${week + 1} steht nicht unter seiner Woche',
      );
    }
  });

  testWidgets('Gesamtziel zeigt Wochen-Soll und Prozent', (tester) async {
    await tester.pumpWidget(_board());

    // 28 + 12 = 40 im Zeitraum → 10 pro Woche; 26 von 40 erledigt = 65 %.
    expect(find.text('10× pro Woche'), findsOneWidget);
    expect(find.text('65 %'), findsOneWidget);
    expect(find.text('26 von 40 in 4 Wochen'), findsOneWidget);
  });
}
