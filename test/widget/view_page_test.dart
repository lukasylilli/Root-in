import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/features/view/overview/overview_board.dart';
import 'package:root_in/features/view/overview/overview_fullscreen_page.dart';
import 'package:root_in/features/view/presentation/view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

final _today = DateTime(2026, 7, 30); // Donnerstag der vierten Woche

Future<void> _pump(WidgetTester tester, AppDatabase db, Widget page) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        timeServiceProvider.overrideWithValue(TestTimeService(_today)),
      ],
      child: localizedApp(page),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpViewPage(WidgetTester tester, AppDatabase db) =>
    _pump(tester, db, const ViewPage());

Future<void> _addHabits(AppDatabase db, List<String> names) async {
  for (final name in names) {
    await db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: name,
        colorValue: 0xFF2E7D5B,
        category: const Value('Allgemein'),
        goalType: HabitGoalType.checkbox,
      ),
    );
  }
}

void main() {
  testWidgets('Übersicht liegt zwischen Woche und Monat', (tester) async {
    final db = createTestDatabase();
    await _pumpViewPage(tester, db);

    final tabs = tester
        .widgetList<Tab>(find.byType(Tab))
        .map((tab) => tab.text)
        .toList();
    expect(tabs, ['Woche', 'Übersicht', 'Monat', 'Jahr']);

    // Die Seite muss wissen, an welcher Stelle sie steht, um beim Wechsel auf
    // Querformat zu sperren (siehe OverviewTab.tabIndex).
    expect(tabs.indexOf('Übersicht'), ViewPage.overviewTabIndex);

    await disposeAndFlush(tester);
  });

  testWidgets('Übersicht-Tab zeigt das Board mit einer Zeile je Gewohnheit', (
    tester,
  ) async {
    final db = createTestDatabase();
    await _addHabits(db, ['Laufen', 'Lesen']);
    await db.habitCompletionDao.setCompleted(1, DateTime(2026, 7, 8));

    await _pumpViewPage(tester, db);
    await tester.tap(find.text('Übersicht'));
    await tester.pumpAndSettle();

    expect(find.byType(OverviewBoard), findsOneWidget);
    // Erste Woche beginnt drei Wochen vor der laufenden, also am 6. Juli.
    expect(
      find.byKey(ValueKey('cell-1-${DateTime(2026, 7, 6).toIso8601String()}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('cell-2-${DateTime(2026, 8, 2).toIso8601String()}')),
      findsOneWidget,
    );

    await disposeAndFlush(tester);
  });

  testWidgets('Übersicht-Tab führt ins Vollbild', (tester) async {
    // Im Tab bleibt von der Höhe nach AppBar/TabBar/Bottom-Nav so wenig übrig,
    // dass die als Ganzes skalierte Bühne winzig wird — das Vollbild ist der
    // Ausweg (siehe overview_fullscreen_page.dart). Hier nur der Knopf; die
    // Route selbst hängt im app_router, die Seite wird unten direkt geprüft.
    final db = createTestDatabase();
    await _addHabits(db, ['Laufen']);

    await _pumpViewPage(tester, db);
    await tester.tap(find.text('Übersicht'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.open_in_full), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('Vollbild-Seite zeigt dieselbe Bühne ohne Tab-Leiste', (
    tester,
  ) async {
    final db = createTestDatabase();
    await _addHabits(db, ['Laufen']);
    await _pump(tester, db, const OverviewFullscreenPage());

    expect(find.byType(OverviewBoard), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
    expect(find.byIcon(Icons.close_fullscreen), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('Ohne Gewohnheiten steht statt des Boards ein Hinweis', (
    tester,
  ) async {
    final db = createTestDatabase();
    await _pumpViewPage(tester, db);
    await tester.tap(find.text('Übersicht'));
    await tester.pumpAndSettle();

    expect(find.byType(OverviewBoard), findsNothing);
    expect(find.text('Noch keine Gewohnheiten angelegt.'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  group('Tab-Navigation (PLAN.md Phase 13)', () {
    testWidgets('jeder Tab zeigt seinen eigenen Zeitraum-Titel', (tester) async {
      final db = createTestDatabase();
      await _addHabits(db, ['Laufen', 'Lesen']);
      await db.habitCompletionDao.setCompleted(1, _today);

      await _pumpViewPage(tester, db);

      // Woche steht beim Öffnen vorn.
      expect(find.text('Diese Woche'), findsOneWidget);
      expect(find.text('Dieser Monat'), findsNothing);

      for (final (tab, title) in [
        ('Monat', 'Dieser Monat'),
        ('Jahr', 'Letzte 12 Monate'),
        ('Woche', 'Diese Woche'),
      ]) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();

        expect(find.text(title), findsOneWidget, reason: 'Tab „$tab"');
        expect(tester.takeException(), isNull, reason: 'Tab „$tab"');
      }

      await disposeAndFlush(tester);
    });

    testWidgets('leerer Bestand bricht keinen der vier Tabs', (tester) async {
      // Der häufigste Absturz-Kandidat (PLAN.md Phase 21.3): alle Diagramme
      // ohne einen einzigen Eintrag. Ohne Gewohnheiten steht in jedem Tab ein
      // Leer-Hinweis statt eines Diagramms.
      final db = createTestDatabase();
      await _pumpViewPage(tester, db);

      for (final tab in ['Übersicht', 'Monat', 'Jahr', 'Woche']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Tab „$tab"');
      }

      await disposeAndFlush(tester);
    });

    testWidgets('Jahr-Tab zeigt den Trend gebündelt als Wochenmittel', (
      tester,
    ) async {
      // Verbindet die Bündelung aus Phase 13 mit der Seite, für die sie
      // gebaut wurde: Der Jahr-Zeitraum sind 52 Kalenderwochen — als
      // Tageswerte gezeichnet war die Linie unlesbar (2026-07-26).
      final db = createTestDatabase();
      await _addHabits(db, ['Laufen']);
      await db.habitCompletionDao.setCompleted(1, _today);

      await _pumpViewPage(tester, db);
      await tester.tap(find.text('Jahr'));
      await tester.pumpAndSettle();

      expect(find.text('Wochenmittel'), findsOneWidget);

      // Die Woche bleibt bei Tageswerten — dort sind es vier Punkte.
      await tester.tap(find.text('Woche'));
      await tester.pumpAndSettle();
      expect(find.text('Wochenmittel'), findsNothing);

      await disposeAndFlush(tester);
    });
  });
}
