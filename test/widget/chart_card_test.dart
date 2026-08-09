import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/utils/date_utils.dart';
import 'package:root_in/core/widgets/chart_card.dart';
import 'package:root_in/data/models/category_breakdown.dart';

import '../support/localized_app.dart';

void main() {
  testWidgets('CategoryBarChart zeigt Kategorie-Labels', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: CategoryBarChart(
            data: const [
              CategoryBreakdown(category: 'Sprachenlernen', count: 5),
              CategoryBreakdown(category: 'Allgemein', count: 2),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Sprachenlernen'), findsOneWidget);
    expect(find.text('Allgemein'), findsOneWidget);
  });

  testWidgets('CategoryBarChart zeigt Leer-Hinweis ohne Daten', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(const Scaffold(body: CategoryBarChart(data: []))),
    );

    expect(find.text('Noch keine Daten für diesen Zeitraum.'), findsOneWidget);
  });

  testWidgets('ProgressTrendChart rendert ohne Fehler mit Daten', (
    tester,
  ) async {
    final start = DateTime(2026, 7, 6);
    final end = DateTime(2026, 7, 12);

    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: ProgressTrendChart(
            start: start,
            end: end,
            intensities: {DateTime(2026, 7, 8): 0.5, DateTime(2026, 7, 9): 1.0},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('CategoryPieChart zeigt eine Kategorie-Legende', (tester) async {
    // Die Prozent-Beschriftung der Segmente zeichnet fl_chart direkt auf
    // den Canvas (PieChartSectionData.title) — kein Text-Widget, daher
    // hier nur die Legende (echte Text-Widgets) geprüft.
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: CategoryPieChart(
            data: const [
              CategoryBreakdown(category: 'Sprachenlernen', count: 3),
              CategoryBreakdown(category: 'Allgemein', count: 1),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Sprachenlernen'), findsOneWidget);
    expect(find.text('Allgemein'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CategoryPieChart zeigt Leer-Hinweis ohne Daten', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(const Scaffold(body: CategoryPieChart(data: []))),
    );

    expect(find.text('Noch keine Daten für diesen Zeitraum.'), findsOneWidget);
  });

  group('CategoryBarChart — Achsen (PLAN.md Phase 13)', () {
    // Regression zur offenen Frage vom 2026-07-26: Die Y-Achse trug zwei
    // Zahlen dicht übereinander (fl_chart beschriftet zusätzlich zum
    // Intervall immer den Rand `maxY`), die X-Beschriftungen liefen
    // ineinander.
    testWidgets('Y-Achse zeigt nur 0 und den Höchstwert', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(
            body: CategoryBarChart(
              data: [
                CategoryBreakdown(category: 'Grammatik', count: 137),
                CategoryBreakdown(category: 'Wortschatz', count: 42),
              ],
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('137'), findsOneWidget);
      // Der obere Rand ist maxCount + 1 — genau die Zahl, die fl_chart
      // zusätzlich beschriften würde.
      expect(find.text('138'), findsNothing);
      // Nichts dazwischen: sonst ist die Filterung wieder weg.
      expect(find.text('42'), findsNothing);
    });

    testWidgets('X-Beschriftung bleibt in ihrer Spaltenbreite', (tester) async {
      const names = [
        'Grammatik üben',
        'Wortschatz auswendig',
        'Lesen und Hören',
        'Schreiben',
        'Sprechen mit Partner',
        'Auswendiglernen',
      ];

      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: CategoryBarChart(
                  data: [
                    for (final name in names)
                      CategoryBreakdown(category: name, count: 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      // (360 - 34 Y-Achse) / 6 Kategorien, minus 12 Luft zum Nachbarn. Ohne
      // die Breitenbegrenzung setzt fl_chart den vollen Namen mittig unter
      // den Balken — dann ist ein Label breiter als seine Spalte und
      // überlappt die Nachbarn.
      const slotWidth = (360 - 34) / 6 - 12;
      for (final name in names) {
        final label = find.text(name);
        expect(label, findsOneWidget, reason: '„$name" fehlt an der Achse');
        expect(tester.getSize(label).width, lessThanOrEqualTo(slotWidth));
      }
    });
  });

  group('trendBucketDays', () {
    // Regression zur offenen Frage vom 2026-07-26 („Herz-Vorhofflimmern"):
    // ~365 Punkte auf ~700 px sind unlesbar.
    test('kurze Zeiträume bleiben bei Tageswerten', () {
      expect(trendBucketDays(7), 1);
      expect(trendBucketDays(31), 1);
      expect(trendBucketDays(90), 1);
    });

    test('Jahr-Zeitraum bündelt auf Wochen', () {
      expect(trendBucketDays(91), 7);
      expect(trendBucketDays(364), 7);
    });

    test('sehr lange Zeiträume bündeln auf Monate', () {
      expect(trendBucketDays(631), 30);
      expect(trendBucketDays(3650), 30);
    });

    test('nie mehr als ~90 Punkte, solange Monate reichen', () {
      for (final days in [7, 90, 91, 364, 630]) {
        expect((days / trendBucketDays(days)).ceil(), lessThanOrEqualTo(90));
      }
    });
  });

  group('trendSeries', () {
    test('ein Punkt je Tag im kurzen Zeitraum', () {
      final series = trendSeries(
        DateTime(2026, 7, 6),
        DateTime(2026, 7, 12),
        {DateTime(2026, 7, 8): 0.5},
      );

      expect(series.bucketDays, 1);
      expect(series.values.length, 7);
      expect(series.values[2], 50);
      expect(series.values[0], 0);
    });

    test('Wochenmittel über ein Jahr', () {
      // 364 Tage = genau 52 volle Wochen.
      final start = DateTime(2025, 8, 4);
      final end = DateTime(2026, 8, 2);
      final intensities = {
        // Die erste Woche zur Hälfte erledigt, sonst nichts.
        for (var i = 0; i < 7; i++) addDays(start, i): i.isEven ? 1.0 : 0.0,
      };

      final series = trendSeries(start, end, intensities);

      expect(series.bucketDays, 7);
      expect(series.values.length, 52);
      // 4 von 7 Tagen erledigt.
      expect(series.values.first, closeTo(4 / 7 * 100, 0.001));
      expect(series.values[1], 0);
    });

    test('angebrochenes letztes Bündel wird nicht verdünnt', () {
      // 92 Tage = 13 Wochen + 1 Tag. Der letzte Tag steht allein und ist
      // voll erledigt — er muss als 100 % erscheinen, nicht als 1/7 davon.
      //
      // `addDays` statt `Duration(days: …)`: Der Zeitraum überspringt die
      // Sommerzeit-Umstellung, und eine Dauer von 91 Tagen landet dann um
      // 01:00 Uhr statt um Mitternacht — der Schlüssel träfe keinen Tag
      // (siehe PLAN.md Phase 2, DST-sichere Datumsarithmetik).
      final start = DateTime(2026, 1, 1);
      final end = addDays(start, 91);

      final series = trendSeries(start, end, {end: 1.0});

      expect(series.bucketDays, 7);
      expect(series.values.length, 14);
      expect(series.values.last, 100);
    });
  });

  testWidgets('ProgressTrendChart nennt die Bündelung ab dem Jahr-Zeitraum', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: ProgressTrendChart(
            start: DateTime(2025, 8, 4),
            end: DateTime(2026, 8, 2),
            intensities: const {},
          ),
        ),
      ),
    );

    // Ohne diesen Hinweis hielte man das Wochenmittel für Tageswerte.
    expect(find.text('Wochenmittel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProgressTrendChart schweigt bei Tageswerten', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: ProgressTrendChart(
            start: DateTime(2026, 7, 6),
            end: DateTime(2026, 7, 12),
            intensities: const {},
          ),
        ),
      ),
    );

    expect(find.text('Wochenmittel'), findsNothing);
    expect(find.text('Monatsmittel'), findsNothing);
  });

  testWidgets('Bündelungs-Hinweis steht auch auf Persisch rechts', (
    tester,
  ) async {
    // Am Gerät gefunden: Mit `TextAlign.end` rutschte der Hinweis auf
    // Persisch nach links — direkt auf die Y-Beschriftung „100 %". Die
    // Y-Achse liegt in jeder Sprache physisch links, der Hinweis gehört
    // deshalb immer nach rechts.
    const width = 320.0;
    await tester.pumpWidget(
      localizedApp(
        locale: const Locale('fa'),
        Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: ProgressTrendChart(
                start: DateTime(2025, 8, 4),
                end: DateTime(2026, 8, 2),
                intensities: const {},
              ),
            ),
          ),
        ),
      ),
    );

    final hint = find.text('میانگین هفتگی');
    expect(hint, findsOneWidget);

    final chartLeft = tester.getTopLeft(find.byType(ProgressTrendChart)).dx;
    expect(
      tester.getTopLeft(hint).dx - chartLeft,
      greaterThan(width / 2),
      reason: 'Der Hinweis liegt in der linken Hälfte, über der Y-Achse',
    );
  });

  testWidgets('ProgressTrendChart bleibt 180 hoch — auch mit Hinweis', (
    tester,
  ) async {
    // Das Home-Screen-Widget rendert dieses Diagramm in eine Bildfläche von
    // 320×200 (home_widget_service.dart). Wüchse es mit dem Hinweis, wäre
    // das Bild auf dem Startbildschirm abgeschnitten.
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: ProgressTrendChart(
                start: DateTime(2025, 8, 4),
                end: DateTime(2026, 8, 2),
                intensities: const {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ProgressTrendChart)).height, 180);
  });
}
