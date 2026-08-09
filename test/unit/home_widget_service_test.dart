import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/home_widget_service.dart';
import 'package:root_in/core/widgets/dashboard/dashboard_widget_type.dart';
import 'package:root_in/data/models/daily_progress.dart';

import '../support/localized_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('schreibt Prozent und Untertitel unter den vereinbarten Schlüsseln', () async {
    // Diese Schlüssel liest RootInWidgetProvider.kt wieder aus — weichen
    // sie ab, bleibt das Widget stumm, ohne dass etwas abstürzt.
    await const HomeWidgetService().updateProgress(
      const DailyProgress(completedCount: 3, totalCount: 4, points: 30),
      testL10n(),
    );

    final saves = calls.where((c) => c.method == 'saveWidgetData').toList();
    expect(saves, hasLength(2));

    final percent = saves.firstWhere(
      (c) => c.arguments['id'] == HomeWidgetService.percentKey,
    );
    expect(percent.arguments['data'], 75);

    final subtitle = saves.firstWhere(
      (c) => c.arguments['id'] == HomeWidgetService.subtitleKey,
    );
    // Phase 23: Das Widget nennt den **offenen Rest**, nicht den Stand —
    // „Noch 1 offen" bewegt, „3/4 erledigt" beschreibt nur.
    expect(subtitle.arguments['data'], 'Noch 1 offen');
  });

  test('Widget meldet den erledigten Tag statt einer Null', () async {
    await const HomeWidgetService().updateProgress(
      const DailyProgress(completedCount: 4, totalCount: 4, points: 40),
      testL10n(),
    );

    final subtitle = calls
        .where((c) => c.method == 'saveWidgetData')
        .firstWhere((c) => c.arguments['id'] == HomeWidgetService.subtitleKey);
    expect(subtitle.arguments['data'], 'Heute alles erledigt');
  });

  test('stößt eine Aktualisierung des Android-Widgets an', () async {
    await const HomeWidgetService().updateProgress(
      const DailyProgress(completedCount: 0, totalCount: 0, points: 0),
      testL10n(),
    );

    final update = calls.singleWhere((c) => c.method == 'updateWidget');
    expect(update.arguments['android'], HomeWidgetService.progressProvider);
  });

  test('rundet auf ganze Prozent und verträgt 0 Gewohnheiten', () async {
    await const HomeWidgetService().updateProgress(
      const DailyProgress(completedCount: 0, totalCount: 0, points: 0),
      testL10n(),
    );

    final percent = calls.firstWhere(
      (c) =>
          c.method == 'saveWidgetData' &&
          c.arguments['id'] == HomeWidgetService.percentKey,
    );
    expect(percent.arguments['data'], 0);
  });

  test('chartKeyFor bildet den Schlüssel wie die Kotlin-Seite', () {
    // Muss zu ChartWidgetProviders.kt (dataKey = "chart_<name>") passen.
    expect(
      HomeWidgetService.chartKeyFor(DashboardWidgetType.matrixGrid),
      'chart_matrixGrid',
    );
    expect(
      HomeWidgetService.chartKeyFor(DashboardWidgetType.monthlyBar),
      'chart_monthlyBar',
    );
  });

  test('updateColorTiles schreibt Katalog und Werte je Gewohnheit', () async {
    // Muss zu ColorTileWidgetProvider.kt / ColorTileConfigActivity.kt passen.
    await const HomeWidgetService().updateColorTiles([
      (
        id: 7,
        name: 'Laufen',
        colorValue: 0xFFF2621F,
        streak: 3,
        doneToday: true,
      ),
    ]);

    final saves = {
      for (final call in calls.where((c) => c.method == 'saveWidgetData'))
        call.arguments['id']: call.arguments['data'],
    };

    expect(saves['tile_habit_ids'], '7');
    expect(saves['tile_name_7'], 'Laufen');
    expect(saves['tile_streak_7'], 3);
    expect(saves['tile_done_7'], isTrue);

    // Vorzeichenbehaftet: ungewandelt läge der Wert über Int.MAX_VALUE und
    // Android legte ihn als Long ab — Kotlins getInt stürzt darauf ab.
    expect(saves['tile_color_7'], 0xFFF2621F.toSigned(32));
    expect(saves['tile_color_7'], lessThan(0));

    final update = calls.lastWhere((c) => c.method == 'updateWidget');
    expect(update.arguments['android'], HomeWidgetService.colorTileProvider);
  });

  test('Ring-/Checklist-Schlüssel passen zur Kotlin-Seite', () {
    // Muss zu RingWidgetProvider/ChecklistWidgetProvider (dataKey) passen.
    expect(HomeWidgetService.ringKey, 'extra_ring');
    expect(HomeWidgetService.checklistKey, 'extra_checklist');
    expect(HomeWidgetService.ringProvider, 'RingWidgetProvider');
    expect(HomeWidgetService.checklistProvider, 'ChecklistWidgetProvider');
  });
}
