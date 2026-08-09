import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/theme/app_theme_variant.dart';
import 'package:root_in/core/widgets/week_checklist.dart';

import '../support/localized_app.dart';

void main() {
  final tokens = AppThemeVariant.blue.tokens(Brightness.dark);
  final monday = DateTime(2026, 7, 20);

  Future<void> pump(
    WidgetTester tester, {
    required DateTime today,
    Locale locale = const Locale('de'),
  }) {
    return tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: WeekChecklist(
            weekStart: monday,
            today: today,
            intensities: {
              DateTime(2026, 7, 20): 1.0, // Mo erledigt
              DateTime(2026, 7, 22): 0.5, // Mi teilweise
            },
            tokens: tokens,
          ),
        ),
        locale: locale,
      ),
    );
  }

  testWidgets('zeigt sieben Tageskreise mit Wochentags-Initialen', (
    tester,
  ) async {
    await pump(tester, today: DateTime(2026, 7, 23));

    for (var i = 0; i < 7; i++) {
      expect(find.byKey(ValueKey(DateTime(2026, 7, 20 + i))), findsOneWidget);
    }
    // M D M D F S S → M/D/S je zweimal, F einmal.
    expect(find.text('M'), findsNWidgets(2));
    expect(find.text('D'), findsNWidgets(2));
    expect(find.text('F'), findsOneWidget);
    expect(find.text('S'), findsNWidgets(2));
  });

  testWidgets('Wochentags-Initialen folgen der gewählten Sprache', (
    tester,
  ) async {
    await pump(
      tester,
      today: DateTime(2026, 7, 23),
      locale: const Locale('en'),
    );

    // M T W T F S S → T/S je zweimal, M/W/F je einmal.
    expect(find.text('M'), findsOneWidget);
    expect(find.text('T'), findsNWidgets(2));
    expect(find.text('W'), findsOneWidget);
    expect(find.text('S'), findsNWidgets(2));
  });

  testWidgets('erledigte Tage zeigen ein Häkchen, offene nicht', (
    tester,
  ) async {
    await pump(tester, today: DateTime(2026, 7, 23));

    // Mo (1.0) und Mi (0.5) sind erledigt → genau 2 Häkchen.
    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });
}
