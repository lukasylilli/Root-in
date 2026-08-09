import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/widgets/dashboard/dashboard_section.dart';
import 'package:root_in/core/widgets/dashboard/dashboard_widget_type.dart';
import 'package:root_in/data/local/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';

void main() {
  testWidgets(
    'Anpassen-Modus erlaubt Entfernen und Hinzufügen von Widgets',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(createTestDatabase()),
          ],
          child: localizedApp(
            Scaffold(
              body: DashboardSection(
                pageId: 'test_page',
                availableTypes: const [
                  DashboardWidgetType.matrixGrid,
                  DashboardWidgetType.categoryBar,
                ],
                defaultTypes: const [DashboardWidgetType.matrixGrid],
                range: (start: DateTime(2026, 7, 1), end: DateTime(2026, 7, 20)),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matrix-Grid'), findsOneWidget);
      expect(find.text('Typ von Gewohnheit (Balken)'), findsNothing);

      await tester.tap(find.text('Anpassen'));
      await tester.pumpAndSettle();

      expect(find.text('Typ von Gewohnheit (Balken)'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(ActionChip, 'Typ von Gewohnheit (Balken)'),
      );
      await tester.pumpAndSettle();

      expect(
        prefs.getStringList('dashboard_layout_test_page'),
        containsAll(['matrixGrid', 'categoryBar']),
      );

      await tester.tap(find.widgetWithText(TextButton, 'Entfernen').first);
      await tester.pumpAndSettle();

      expect(
        prefs.getStringList('dashboard_layout_test_page'),
        isNot(contains('matrixGrid')),
      );

      await disposeAndFlush(tester);
    },
  );
}
