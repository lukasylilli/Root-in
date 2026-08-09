import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/l10n/app_language.dart';
// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// import 'package:root_in/core/services/purchase_service.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/theme/app_theme_variant.dart';
import 'package:root_in/features/guide/presentation/guide_document.dart';
import 'package:root_in/features/home/presentation/ascent_source.dart';
import 'package:root_in/features/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../support/fake_purchase_service.dart';
import '../support/localized_app.dart';

void main() {
  testWidgets(
    'Darstellungsmodus-Auswahl ändert themeModeProvider und wird persistiert',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.system);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedApp(const SettingsPage()),
        ),
      );

      await tester.tap(find.text('Dunkel'));
      await tester.pump();

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');
    },
  );

  testWidgets(
    'Farb-Variante ändert themeVariantProvider und wird persistiert',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeVariantProvider), AppThemeVariant.green);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedApp(const SettingsPage()),
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Blau'));
      await tester.pump();

      expect(container.read(themeVariantProvider), AppThemeVariant.blue);
      expect(prefs.getString('theme_variant'), 'blue');
    },
  );

  testWidgets(
    'Animations-Quelle ändert ascentSourceProvider und wird persistiert',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(ascentSourceProvider), AscentSource.today);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedApp(const SettingsPage()),
        ),
      );

      await tester.tap(
        find.widgetWithText(ChoiceChip, 'Fortschritt dieses Jahr'),
      );
      await tester.pump();

      expect(container.read(ascentSourceProvider), AscentSource.year);
      expect(prefs.getString('ascent_source'), 'year');
    },
  );

  testWidgets(
    'Sprach-Auswahl ändert appLanguageProvider und wird persistiert',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appLanguageProvider), AppLanguage.system);
      // System = kein festes Locale, MaterialApp löst selbst auf.
      expect(container.read(appLocaleProvider), isNull);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedApp(const SettingsPage()),
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Englisch'));
      await tester.pump();

      expect(container.read(appLanguageProvider), AppLanguage.english);
      expect(container.read(appLocaleProvider), const Locale('en'));
      expect(prefs.getString('app_language'), 'english');
    },
  );

  testWidgets(
    'Persisch schaltet Oberfläche und Inhalte um',
    (tester) async {
      // Phase 18: Persisch ist eine vollwertige App-Sprache. Bis Phase 17.2
      // blieb die Oberfläche deutsch, weil `app_fa.arb` fehlte — der
      // Sonderweg über `contentLanguageCode` ist ersatzlos entfallen.
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedApp(const SettingsPage()),
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'فارسی'));
      await tester.pump();

      expect(container.read(appLanguageProvider), AppLanguage.persian);
      expect(prefs.getString('app_language'), 'persian');

      // Oberfläche **und** Inhalte: persisch — ein Schalter für beides.
      expect(container.read(appLocaleProvider), const Locale('fa'));
      expect(container.read(guideLanguageProvider), 'fa');
    },
  );

  testWidgets('Kontakt-uns-Eintrag ist sichtbar', (tester) async {
    // Öffnet echt ein externes Ziel (url_launcher) — hier nur geprüft, dass
    // die Kachel existiert, nicht der tatsächliche Launch (kein
    // Platform-Channel-Mock in reinen Widget-Tests).
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: localizedApp(const SettingsPage()),
      ),
    );

    // Liegt am Seitenende und ist im Test-Viewport erst nach dem Scrollen
    // gemountet (lazy ListView).
    await tester.scrollUntilVisible(
      find.text('Kontakt uns'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kontakt uns'), findsOneWidget);
  });
}
