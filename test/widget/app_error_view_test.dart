import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/widgets/app_error_view.dart';

/// PLAN.md 31.7 — die Fehlerseite statt der stummen grauen Fläche.
///
/// Geprüft wird, was sie tragen muss: Sie baut **ohne** App darüber (kein
/// Theme, keine Übersetzungen — genau die Lage, in der sie erscheint), zeigt
/// den Fehlertext und den Knopf „Neu laden\", und in einer kleinen Fläche
/// (eine einzelne Kachel) fällt sie auf Flutters schlichte Fehlerfläche
/// zurück, statt überzulaufen.
void main() {
  final details = FlutterErrorDetails(
    exception: StateError('Testfehler 31.7'),
  );

  testWidgets('volle Fläche: Erklärung, Fehlertext und Neu-laden-Knopf',
      (tester) async {
    await tester.pumpWidget(AppErrorView(details: details));

    expect(find.byKey(const Key('app-error-reload')), findsOneWidget);
    expect(find.textContaining('Testfehler 31.7'), findsOneWidget);
    expect(find.textContaining('Neu laden'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Der Knopf ist antippbar (außerhalb des Browsers tut er nichts).
    await tester.tap(find.byKey(const Key('app-error-reload')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('kleine Fläche: schlichte Fehlerfläche, kein Überlauf',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 120,
            height: 60,
            child: AppErrorView(details: details),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('app-error-reload')), findsNothing);
    expect(find.byType(ErrorWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
