import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/default_categories.dart';
import 'core/l10n/app_language.dart';
// PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
// import 'dart:async';
// import 'core/services/ads_service.dart';
// import 'core/services/purchase_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/home_widget_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/web_storage/request_persistent_storage.dart';
import 'core/utils/platform_support.dart';
import 'data/repositories/habit_repository.dart';
import 'l10n/gen/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Die gespeicherte Sprache wird schon vor dem ersten Frame gebraucht: für
  // die iOS-Notification-Kategorie (Snooze-Button, wird bei der
  // Initialisierung registriert) und für die Standard-Kategorien einer
  // frischen Installation.
  final locale = resolveLocale(SettingsService(prefs).loadLanguage());
  final l10n = lookupAppLocalizations(locale);

  final notificationService = NotificationService(
    FlutterLocalNotificationsPlugin(),
  );
  await notificationService.initialize(locale);

  // Log-Button der Farbkacheln (siehe PLAN.md Phase 10.6d): Android startet
  // dafür ein eigenes Isolate und ruft diese Top-Level-Funktion.
  //
  // Anders als die Methoden des `HomeWidgetService` ist das ein **direkter**
  // Aufruf ins Plugin; er braucht die Weiche deshalb hier (PLAN.md Phase 26.1).
  if (supportsHomeScreenWidgets) {
    await HomeWidget.registerInteractivityCallback(colorTileInteractionCallback);
  }

  // Im Browser darum bitten, den Speicher dieser Seite dauerhaft zu behalten
  // (PLAN.md Phase 26.8). Steht **vor** dem ersten Datenbank-Zugriff: Die
  // Bitte gilt dem ganzen Ursprung, und manche Browser fragen dafür beim
  // Nutzer nach — die Antwort soll vorliegen, bevor die App Daten anlegt.
  // Auf Android/iOS kehrt der Aufruf sofort mit `false` zurück.
  await requestPersistentStorage();

  // Supabase starten, **falls** ein Projekt konfiguriert ist (PLAN.md Phase
  // 27.3). Ohne Schlüssel kehrt der Aufruf sofort zurück und die App verhält
  // sich wie vor Phase 27.
  //
  // ⚠️ Der Aufruf darf den Start **nie** verhindern: `initialize()` fängt
  // jeden Fehler ab und meldet nur `false`. Ein Server, der nicht antwortet,
  // ist kein Grund, eine App nicht zu starten, die ohnehin lokal arbeitet.
  await const AuthService().initialize();

  // Expliziter Container statt `ProviderScope`: die Standard-Kategorien
  // müssen in der gewählten Sprache stehen, bevor die erste Seite baut (siehe
  // PLAN.md Phase 11.5 und 21.1) — dafür braucht es Provider-Zugriff hier.
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
  );
  await container.read(habitRepositoryProvider).ensureDefaultCategories(
    defaultCategoryNames(l10n),
  );

  // PHASE 20 (2026-08-01): Werbung deaktiviert — zum Wiederaktivieren diesen Block einkommentieren.
  // Werbung/Kauf (siehe PLAN.md Phase 14): Der Notifier liest den gemerkten
  // Kaufstatus und fragt im Hintergrund bei Google Play nach — damit steht
  // schon vor dem ersten Frame fest, ob ein Banner überhaupt in Frage kommt.
  // Der Schalter deckt beides ab: den gemerkten Kauf und den vorübergehenden
  // Not-Schalter `AdConfig.adsDisabledForEveryone`.
  // if (!container.read(adsRemovedProvider)) {
  //   // Bewusst ohne `await`: der Start soll nicht auf das Werbe-SDK warten.
  //   // `BannerAdSlot` wartet vor dem ersten Abruf auf denselben Future.
  //   unawaited(container.read(adsServiceProvider).initialize());
  // }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RootInApp(),
    ),
  );
}
