import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/features/categories/presentation/categories_page.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';

void main() {
  testWidgets('Kategorie anlegen, umbenennen und löschen', (tester) async {
    final db = createTestDatabase();
    // Seit Phase 11.5 legt nicht mehr die Migration die Kategorien an,
    // sondern der App-Start in der gewählten Sprache — hier bewusst nur
    // **eine**, damit der Test die Zeilen der Liste eindeutig treffen kann.
    // Dass der Erststart sieben anlegt, prüft `category_dao_test.dart`.
    await db.categoryDao.ensureDefaultCategories(<String>['Allgemein']);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: localizedApp(const CategoriesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Allgemein'), findsOneWidget);

    // Anlegen.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sport');
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(find.text('Sport'), findsOneWidget);

    Finder rowFor(String name) =>
        find.ancestor(of: find.text(name), matching: find.byType(ListTile));

    // Umbenennen (nur die „Sport"-Zeile betreffen, „Allgemein" bleibt).
    await tester.tap(
      find.descendant(
        of: rowFor('Sport'),
        matching: find.byIcon(Icons.edit_outlined),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Fitness');
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(find.text('Fitness'), findsOneWidget);
    expect(find.text('Sport'), findsNothing);
    expect(find.text('Allgemein'), findsOneWidget);

    // Löschen.
    await tester.tap(
      find.descendant(
        of: rowFor('Fitness'),
        matching: find.byIcon(Icons.delete_outline),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fitness'), findsNothing);
    expect(find.text('Allgemein'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('Nachrüst-Knopf legt die fehlenden Standard-Kategorien an', (
    tester,
  ) async {
    final db = createTestDatabase();
    // Bestandsnutzer aus der Zeit vor Phase 21: eigene Kategorie, und eine,
    // die zufällig auch Standard ist.
    await db.categoryDao.ensureDefaultCategories(<String>['Allgemein']);
    await db.categoryDao.getOrCreateCategory('Lesen');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: localizedApp(const CategoriesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Grammatik'), findsNothing);

    await tester.tap(find.text('Standard-Kategorien anlegen'));
    await tester.pumpAndSettle();

    // Sechs fehlten — „Lesen" war schon da und darf nicht doppelt erscheinen.
    expect(find.text('6 Kategorien ergänzt.'), findsOneWidget);
    expect(find.text('Grammatik'), findsOneWidget);
    expect(find.text('Lesen'), findsOneWidget);
    // Die eigene Kategorie bleibt unangetastet.
    expect(find.text('Allgemein'), findsOneWidget);

    await disposeAndFlush(tester);
  });
}
