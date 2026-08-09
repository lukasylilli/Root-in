import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/features/home/presentation/home_progress_animation.dart';

import '../support/localized_app.dart';

void main() {
  Future<void> pumpWith(WidgetTester tester, double percent) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: HomeProgressAnimation(
            percent: percent,
            sourceLabel: 'Fortschritt heute',
          ),
        ),
      ),
    );
    // Die Figur wandert per TweenAnimationBuilder weich zur Zielhöhe; das
    // Sternen-Funkeln läuft dauerhaft, daher pump() statt pumpAndSettle().
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('zeigt den Prozentwert und die gewählte Quelle', (tester) async {
    await pumpWith(tester, 0.42);

    expect(find.text('42'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('Fortschritt heute'), findsOneWidget);
  });

  testWidgets('zeigt bei 100 % die Gipfel-Meldung', (tester) async {
    await pumpWith(tester, 1);

    expect(find.text('100'), findsOneWidget);
    expect(find.text('Gipfel erreicht!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nennt das nächste Camp in Prozent', (tester) async {
    await pumpWith(tester, 0.5);

    // Nächstes Camp nach 50 % ist 60 % → noch 10 %.
    expect(find.text('Noch 10 % bis Camp 60 %'), findsOneWidget);
  });

  testWidgets('begrenzt Werte außerhalb 0..1', (tester) async {
    await pumpWith(tester, 1.8);

    expect(find.text('100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
