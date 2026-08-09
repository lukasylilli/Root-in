import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/widgets/matrix_grid.dart';

void main() {
  testWidgets('MatrixGrid rendert eine Zelle pro Tag im Zeitraum', (
    tester,
  ) async {
    final start = DateTime(2026, 7, 6); // Montag
    final end = DateTime(2026, 7, 19); // Sonntag, 2 volle Wochen

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatrixGrid(
            start: start,
            end: end,
            intensities: {DateTime(2026, 7, 10): 0.5},
          ),
        ),
      ),
    );

    // Jede Zelle trägt ihr Datum als ValueKey.
    expect(find.byKey(ValueKey(DateTime(2026, 7, 6))), findsOneWidget);
    expect(find.byKey(ValueKey(DateTime(2026, 7, 10))), findsOneWidget);
    expect(find.byKey(ValueKey(DateTime(2026, 7, 19))), findsOneWidget);

    // Tag außerhalb des Zeitraums existiert nicht.
    expect(find.byKey(ValueKey(DateTime(2026, 7, 20))), findsNothing);

    // 14 Tage → 14 Zellen (transparente Füllzellen gibt es hier nicht,
    // da der Zeitraum an Wochengrenzen ausgerichtet ist).
    final cells = tester.widgetList<Container>(
      find.byWidgetPredicate(
        (w) => w is Container && w.key is ValueKey<DateTime>,
      ),
    );
    expect(cells.length, 14);
  });

  testWidgets('fitToWidth passt ein ganzes Jahr ohne Überlauf in die Breite', (
    tester,
  ) async {
    // Regression: zuvor skalierte nur die Zelle, der Rand blieb fix — bei
    // ~53 Wochen lief das Grid dadurch über den Rand hinaus (auf der
    // Jahr-Seite als „RIGHT OVERFLOWED BY 69 PIXELS" sichtbar).
    final start = DateTime(2025, 7, 21);
    final end = DateTime(2026, 7, 21);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: MatrixGrid(
              start: start,
              end: end,
              intensities: const {},
              fitToWidth: true,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    // Das Grid darf die vorgegebene Breite nicht überschreiten.
    expect(tester.getSize(find.byType(MatrixGrid)).width, lessThanOrEqualTo(320));
  });
}
