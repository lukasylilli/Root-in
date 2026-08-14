import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/presentation/ascent_source.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme_tokens.dart';
import '../theme/app_theme_variant.dart';

/// Persistiert nutzerwählte App-Einstellungen ([ThemeMode],
/// [AppThemeVariant], [AppLanguage], [AscentSource]). Einzige Stelle, die
/// `shared_preferences` für Design-/Sprach-Einstellungen anfasst — die
/// Einstellungen-Seite ändert nur die jeweiligen Provider, nie direkt Prefs.
class SettingsService {
  const SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = 'theme_mode';
  static const _themeVariantKey = 'theme_variant';
  static const _ascentSourceKey = 'ascent_source';
  static const _languageKey = 'app_language';
  static const _onboardingSeenKey = 'onboarding_seen';
  static const _shareOverviewKey = 'share_include_overview';
  static const _statusNotificationKey = 'status_notification_enabled';
  static const _webStorageHintKey = 'web_storage_hint_seen';

  ThemeMode loadThemeMode() {
    final stored = _prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _prefs.setString(_themeModeKey, mode.name);
  }

  AppThemeVariant loadThemeVariant() {
    final stored = _prefs.getString(_themeVariantKey);
    return AppThemeVariant.values.firstWhere(
      (variant) => variant.name == stored,
      orElse: () => AppThemeVariant.green,
    );
  }

  Future<void> saveThemeVariant(AppThemeVariant variant) {
    return _prefs.setString(_themeVariantKey, variant.name);
  }

  /// Ob die Erststart-Erklärung schon durchlaufen (oder übersprungen) wurde
  /// — siehe PLAN.md Phase 11.6.
  bool loadOnboardingSeen() => _prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> saveOnboardingSeen() {
    return _prefs.setBool(_onboardingSeenKey, true);
  }

  /// Ob der Speicher-Hinweis der Web-Fassung schon quittiert wurde
  /// (PLAN.md Phase 26.8).
  ///
  /// Bewusst ein **eigener** Merker statt eines fünften Onboarding-Schritts:
  /// Das Onboarding läuft nur bei einer frischen Installation. Wer die
  /// Web-Fassung schon benutzt, hat es längst hinter sich — und wäre damit
  /// genau der Nutzer, der den Hinweis nie zu sehen bekäme, obwohl seine
  /// Daten betroffen sind.
  bool loadWebStorageHintSeen() =>
      _prefs.getBool(_webStorageHintKey) ?? false;

  Future<void> saveWebStorageHintSeen() {
    return _prefs.setBool(_webStorageHintKey, true);
  }

  AppLanguage loadLanguage() {
    final stored = _prefs.getString(_languageKey);
    return AppLanguage.values.firstWhere(
      (language) => language.name == stored,
      orElse: () => AppLanguage.system,
    );
  }

  Future<void> saveLanguage(AppLanguage language) {
    return _prefs.setString(_languageKey, language.name);
  }

  AscentSource loadAscentSource() {
    final stored = _prefs.getString(_ascentSourceKey);
    return AscentSource.values.firstWhere(
      (source) => source.name == stored,
      orElse: () => AscentSource.today,
    );
  }

  Future<void> saveAscentSource(AscentSource source) {
    return _prefs.setString(_ascentSourceKey, source.name);
  }

  /// Ob der Übersicht-Block auf der Fortschritts-Karte landet (PLAN.md
  /// Phase 19). Standard `true`: Er ist der Grund, warum die Karte
  /// überarbeitet wurde — wer ihn nicht will, schaltet ihn im Sheet ab.
  bool loadShareIncludeOverview() =>
      _prefs.getBool(_shareOverviewKey) ?? true;

  Future<void> saveShareIncludeOverview(bool include) {
    return _prefs.setBool(_shareOverviewKey, include);
  }

  /// Ob der Tagesstand dauerhaft in der Benachrichtigungsleiste steht
  /// (PLAN.md Phase 23). Standard `true`: Er ist der Grund, warum die Phase
  /// gebaut wurde — wer ihn nicht will, schaltet ihn hier ab.
  bool loadStatusNotificationEnabled() =>
      _prefs.getBool(_statusNotificationKey) ?? true;

  Future<void> saveStatusNotificationEnabled(bool enabled) {
    return _prefs.setBool(_statusNotificationKey, enabled);
  }
}

/// Wird in main.dart mit der echten [SharedPreferences]-Instanz überschrieben
/// (async Initialisierung vor `runApp`).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider muss per ProviderScope-Override gesetzt werden',
  );
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(sharedPreferencesProvider));
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(settingsServiceProvider).loadThemeMode();

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsServiceProvider).saveThemeMode(mode);
  }
}

/// Einziger Schalter für den App-weiten Darstellungsmodus (siehe PLAN.md
/// Abschnitt 9, Design-Token-Prinzip). Settings-UI ruft ausschließlich
/// `ref.read(themeModeProvider.notifier).setThemeMode(...)` auf.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeVariantNotifier extends Notifier<AppThemeVariant> {
  @override
  AppThemeVariant build() => ref.watch(settingsServiceProvider).loadThemeVariant();

  Future<void> setThemeVariant(AppThemeVariant variant) async {
    state = variant;
    await ref.read(settingsServiceProvider).saveThemeVariant(variant);
  }
}

/// Einziger Schalter für die App-weite Farb-Variante (siehe PLAN.md
/// Abschnitt 9, Design-Token-Prinzip, und Phase 6 „weitere Themen").
final themeVariantProvider =
    NotifierProvider<ThemeVariantNotifier, AppThemeVariant>(
      ThemeVariantNotifier.new,
    );

/// Design-Tokens für die gewählte Farb-Variante in der angefragten
/// Helligkeit (siehe PLAN.md Phase 10.6a). Widgets lesen sie über
/// `ref.watch(appTokensProvider(Theme.of(context).brightness))` — die
/// Helligkeit als Family-Schlüssel, weil sie (bei ThemeMode.system) erst
/// aus dem `BuildContext` feststeht, nicht aus einem Provider.
final appTokensProvider = Provider.family<AppThemeTokens, Brightness>(
  (ref, brightness) => ref.watch(themeVariantProvider).tokens(brightness),
);

class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsServiceProvider).loadOnboardingSeen();

  /// Wird am Ende der Erklärung **und** beim Überspringen gerufen.
  Future<void> markSeen() async {
    state = true;
    await ref.read(settingsServiceProvider).saveOnboardingSeen();
  }
}

/// Steuert, ob beim Start die Erststart-Erklärung erscheint (siehe PLAN.md
/// Phase 11.6). Der Router liest den Wert **einmal** beim Aufbau — danach
/// ändert er nur noch, dass beim nächsten Start direkt Home kommt.
final onboardingSeenProvider = NotifierProvider<OnboardingSeenNotifier, bool>(
  OnboardingSeenNotifier.new,
);

class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => ref.watch(settingsServiceProvider).loadLanguage();

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await ref.read(settingsServiceProvider).saveLanguage(language);
  }
}

/// Einziger Schalter für die App-Sprache (siehe PLAN.md Abschnitt 9,
/// Design-Token-Prinzip, und Phase 11).
final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);

/// Was `MaterialApp.locale` erwartet: `null` = Systemsprache verwenden.
final appLocaleProvider = Provider<Locale?>(
  (ref) => ref.watch(appLanguageProvider).locale,
);

/// Konkrete Sprache für Texte **außerhalb** des Widget-Baums — vor allem die
/// Notification-Texte (siehe `core/services/notification_service.dart`), die
/// keinen `BuildContext` haben.
final resolvedLocaleProvider = Provider<Locale>(
  (ref) => resolveLocale(ref.watch(appLanguageProvider)),
);

class AscentSourceNotifier extends Notifier<AscentSource> {
  @override
  AscentSource build() => ref.watch(settingsServiceProvider).loadAscentSource();

  Future<void> setSource(AscentSource source) async {
    state = source;
    await ref.read(settingsServiceProvider).saveAscentSource(source);
  }
}

/// Welche Kennzahl die Berg-Animation speist (siehe PLAN.md Phase 8.6).
final ascentSourceProvider = NotifierProvider<AscentSourceNotifier, AscentSource>(
  AscentSourceNotifier.new,
);

class ShareIncludeOverviewNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsServiceProvider).loadShareIncludeOverview();

  Future<void> set(bool include) async {
    state = include;
    await ref.read(settingsServiceProvider).saveShareIncludeOverview(include);
  }
}

/// Einziger Schalter dafür, ob die Fortschritts-Karte den Übersicht-Block
/// zeigt (siehe PLAN.md Phase 19). Persistiert wie das Dashboard-Layout —
/// wer einmal gewählt hat, bekommt beim nächsten Teilen dieselbe Karte.
final shareIncludeOverviewProvider =
    NotifierProvider<ShareIncludeOverviewNotifier, bool>(
      ShareIncludeOverviewNotifier.new,
    );

class StatusNotificationNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(settingsServiceProvider).loadStatusNotificationEnabled();

  Future<void> set(bool enabled) async {
    state = enabled;
    await ref.read(settingsServiceProvider).saveStatusNotificationEnabled(
      enabled,
    );
  }
}

/// Einziger Schalter für die dauerhafte Tagesstand-Meldung (PLAN.md
/// Phase 23). Gelesen wird er an genau einer Stelle — dem Listener in
/// `app.dart`, der ohnehin den Fortschritt verteilt.
final statusNotificationProvider =
    NotifierProvider<StatusNotificationNotifier, bool>(
      StatusNotificationNotifier.new,
    );
