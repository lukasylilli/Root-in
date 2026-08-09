import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/l10n/app_language.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/features/categories/presentation/categories_page.dart';
import 'package:root_in/features/settings/presentation/settings_page.dart';
import 'package:root_in/features/today/presentation/today_page.dart';
import 'package:root_in/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dispose_and_flush.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

/// Phase 18: Persisch ist eine vollwertige Oberflächen-Sprache. Geprüft wird
/// beides, was dabei schiefgehen kann — fehlende Texte (die App zeigt dann
/// stillschweigend die deutschen) und die Laufrichtung (Flutter dreht nur,
/// wenn die Locale wirklich auf `fa` steht).
void main() {
  const fa = Locale('fa');

  testWidgets('Oberfläche läuft auf Persisch von rechts nach links', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(createTestDatabase()),
          timeServiceProvider.overrideWithValue(
            TestTimeService(DateTime(2026, 7, 20)),
          ),
        ],
        child: localizedApp(const TodayPage(), locale: fa),
      ),
    );
    await tester.pumpAndSettle();

    // Persische Texte statt deutscher Rückfalltexte.
    expect(find.text('امروز'), findsWidgets);

    // Die Laufrichtung kommt aus der Locale, nicht aus einem Sonderfall im
    // Code — steht sie falsch, laufen alle Eigenbauten links herum.
    expect(
      Directionality.of(tester.element(find.byType(TodayPage))),
      TextDirection.rtl,
    );

    await disposeAndFlush(tester);
  });

  testWidgets('Sprachauswahl selbst steht auf Persisch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: localizedApp(const SettingsPage(), locale: fa),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('زبان'), findsOneWidget);
    expect(find.text('ظاهر'), findsOneWidget);
    // Persisch steht in jeder Sprache in der eigenen Schrift.
    expect(find.text('فارسی'), findsOneWidget);
  });

  testWidgets('Standard-Kategorien tragen die persischen Namen', (
    tester,
  ) async {
    // Bindeglied zwischen Phase 18 und 21: Der Erststart legt sie in der
    // gewählten Sprache an — auf Persisch müssen es die sieben Fertigkeiten
    // aus der Anleitung sein (PLAN.md Abschnitt 6).
    SharedPreferences.setMockInitialValues({});
    final db = createTestDatabase();
    await db.categoryDao.ensureDefaultCategories(<String>[
      'دستور زبان',
      'واژگان',
      'حفظ کردن',
      'خواندن',
      'نوشتن',
      'صحبت کردن',
      'شنیدن',
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: localizedApp(const CategoriesPage(), locale: fa),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('دستور زبان'), findsOneWidget);
    expect(find.text('شنیدن'), findsOneWidget);
    expect(find.text('ساخت دسته‌بندی‌های پیش‌فرض'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  test('jeder Schlüssel hat eine persische Fassung', () {
    // Fehlt einer, fällt gen-l10n stillschweigend auf Deutsch zurück — die
    // App liefe, sähe aber gemischt aus. Ein Test findet das sofort, der
    // Blick auf den Bildschirm erst nach dem Durchklicken aller Seiten.
    final de = lookupAppLocalizations(const Locale('de'));
    final faL10n = lookupAppLocalizations(fa);

    // Stellvertretend quer durch die App: Wäre einer der Schlüssel nur in
    // app_de.arb, käme hier der deutsche Text zurück.
    expect(faL10n.navHome, isNot(de.navHome));
    expect(faL10n.navSettings, isNot(de.navSettings));
    expect(faL10n.overviewColBest, isNot(de.overviewColBest));
    expect(faL10n.onboardingWelcomeBody, isNot(de.onboardingWelcomeBody));
    expect(faL10n.shareCardDownloadTitle, isNot(de.shareCardDownloadTitle));
    expect(faL10n.categoriesAddDefaults, isNot(de.categoriesAddDefaults));
    expect(
      faL10n.achievementStreak100Title,
      isNot(de.achievementStreak100Title),
    );
    expect(faL10n.notificationBody, isNot(de.notificationBody));
  });

  test('Persisch ist eine unterstützte Locale und die App-Sprache dafür', () {
    expect(AppLocalizations.supportedLocales, contains(fa));
    // Ohne diesen Schritt bliebe die Oberfläche deutsch (Stand Phase 17.2).
    expect(AppLanguage.persian.locale, fa);
    // Texte ohne BuildContext (Benachrichtigungen) müssen fa auflösen können.
    expect(resolveLocale(AppLanguage.persian), fa);
    expect(lookupAppLocalizations(fa).notificationChannelName, isNotEmpty);
  });
}
