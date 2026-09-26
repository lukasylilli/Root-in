import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/features/home/presentation/ascent_scene_painter.dart';
import 'package:root_in/features/home/presentation/ascent_scene_palette.dart';
import 'package:root_in/features/home/presentation/home_progress_animation.dart';

import '../support/localized_app.dart';

void main() {
  Future<void> pumpWith(
    WidgetTester tester,
    double percent, {
    Locale locale = const Locale('de'),
  }) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: HomeProgressAnimation(
            percent: percent,
            sourceLabel: 'Fortschritt heute',
          ),
        ),
        locale: locale,
      ),
    );
    // Der Pin wandert per TweenAnimationBuilder weich zur Zielstelle, das
    // Gipfel-Funkeln dauert einmalig 2 s — pump() mit fester Zeit hält den
    // Test unabhängig davon.
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

  testWidgets('Gipfel-Funkeln läuft einmal und kommt zur Ruhe', (tester) async {
    await pumpWith(tester, 1);
    // Keine Dauer-Animation mehr (Phase 33): der Baum wird ruhig.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wechsel auf und unter den Gipfel ohne Fehler', (tester) async {
    await pumpWith(tester, 0.3);
    await pumpWith(tester, 1);
    await tester.pump(const Duration(seconds: 3));
    await pumpWith(tester, 0.7);
    expect(find.text('70'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('läuft auch von rechts nach links (Persisch)', (tester) async {
    await pumpWith(tester, 0.6, locale: const Locale('fa'));
    expect(find.text('60'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('malt hell und dunkel, gespiegelt und nicht, ohne Fehler', (
    tester,
  ) async {
    for (final palette in [AscentScenePalette.light, AscentScenePalette.dark]) {
      for (final mirrored in [false, true]) {
        for (final progress in [0.0, 0.2, 0.55, 1.0]) {
          await tester.pumpWidget(
            SizedBox(
              width: 360,
              height: 260,
              child: CustomPaint(
                painter: AscentScenePainter(
                  progress: progress,
                  campFractions: HomeProgressAnimation.campFractions,
                  palette: palette,
                  mirrored: mirrored,
                  spark: progress >= 1 ? 0.5 : 0.0,
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  test('Funkeln: unsichtbar am Anfang, ruhig am Ende', () {
    final start = AscentScenePainter.sparkFrame(0);
    expect(start.scale, 0);
    expect(start.opacity, 0);

    final end = AscentScenePainter.sparkFrame(1);
    expect(end.scale, closeTo(0.8, 1e-9));
    expect(end.opacity, closeTo(0.9, 1e-9));
    expect(end.turn, 0);
  });

  test('Palette folgt dem Darstellungsmodus', () {
    expect(
      AscentScenePalette.of(Brightness.dark),
      same(AscentScenePalette.dark),
    );
    expect(
      AscentScenePalette.of(Brightness.light),
      same(AscentScenePalette.light),
    );
    expect(
      AscentScenePalette.light.progressColor(atSummit: true),
      AscentScenePalette.light.complete,
    );
  });
}
