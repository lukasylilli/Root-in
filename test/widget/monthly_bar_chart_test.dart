import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/widgets/monthly_bar_chart.dart';
import 'package:root_in/data/models/monthly_breakdown.dart';

import '../support/localized_app.dart';

void main() {
  final data = [
    MonthlyBreakdown(month: DateTime(2026, 6), count: 4),
    MonthlyBreakdown(month: DateTime(2026, 7), count: 9),
  ];

  testWidgets('MonthlyBarChart zeigt Monatsnamen und Werte', (tester) async {
    await tester.pumpWidget(
      localizedApp(Scaffold(body: MonthlyBarChart(data: data))),
    );

    expect(find.text('Jun'), findsOneWidget);
    expect(find.text('Jul'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('Monatsnamen folgen der gewählten Sprache', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(body: MonthlyBarChart(data: data)),
        locale: const Locale('en'),
      ),
    );

    // Nur der März unterscheidet sich hier im Kürzel (Mär/Mar) — Jun/Jul
    // sind in beiden Sprachen gleich, taugen also nicht als Nachweis.
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: MonthlyBarChart(
            data: [MonthlyBreakdown(month: DateTime(2026, 3), count: 1)],
          ),
        ),
        locale: const Locale('en'),
      ),
    );

    expect(find.text('Mar'), findsOneWidget);
    expect(find.text('Mär'), findsNothing);
  });

  testWidgets('MonthlyBarChart zeigt Leer-Hinweis ohne Daten', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(const Scaffold(body: MonthlyBarChart(data: []))),
    );

    expect(find.text('Noch keine Daten für diesen Zeitraum.'), findsOneWidget);
  });
}
