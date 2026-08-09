import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/theme/app_theme_variant.dart';
import 'package:root_in/core/widgets/progress_ring.dart';

void main() {
  final tokens = AppThemeVariant.orange.tokens(Brightness.dark);

  testWidgets('zeigt den Prozentwert in der Mitte', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProgressRing(percent: 0.72, tokens: tokens)),
      ),
    );

    expect(find.text('72'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
  });

  testWidgets('begrenzt Werte außerhalb 0..1 und rendert fehlerfrei', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProgressRing(percent: 1.5, tokens: tokens)),
      ),
    );

    expect(find.text('100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('centerLabel ersetzt die Prozentanzeige', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressRing(
            percent: 0.4,
            tokens: tokens,
            centerLabel: const Text('7 Tage'),
          ),
        ),
      ),
    );

    expect(find.text('7 Tage'), findsOneWidget);
    expect(find.text('40'), findsNothing);
  });
}
