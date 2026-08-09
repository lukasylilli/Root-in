import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routing/app_router.dart';
import 'core/services/home_widget_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_utils.dart';
import 'data/local/database.dart';
import 'data/models/daily_progress.dart';
import 'data/repositories/habit_repository.dart';
import 'l10n/gen/app_localizations.dart';

class RootInApp extends ConsumerStatefulWidget {
  const RootInApp({super.key});

  @override
  ConsumerState<RootInApp> createState() => _RootInAppState();
}

class _RootInAppState extends ConsumerState<RootInApp> {
  late final AppLifecycleListener _lifecycle;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refreshAfterBackgroundWrites);

    // Genau einmal: eine bei jedem Build neu erzeugte GoRouter-Instanz würde
    // die Navigation zurücksetzen. Ob die Erklärung fällig ist, steht beim
    // Start ohnehin fest (siehe PLAN.md Phase 11.6).
    _router = createAppRouter(
      showOnboarding: !ref.read(onboardingSeenProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Der Log-Button einer Farbkachel schreibt aus einem **eigenen** Isolate
  /// in die Datenbank (siehe PLAN.md Phase 10.6d). Die Drift-Streams dieser
  /// App-Instanz hängen an der Verbindung des Haupt-Isolates und bekommen
  /// davon nichts mit — beim Zurückkehren in den Vordergrund stoßen wir sie
  /// daher einmal zum Neulesen an.
  void _refreshAfterBackgroundWrites() {
    final db = ref.read(appDatabaseProvider);
    db.markTablesUpdated({db.habitCompletions});
  }

  /// Schreibt den Tagesstand in die Benachrichtigungsleiste (siehe PLAN.md
  /// Phase 23).
  ///
  /// Hängt bewusst am **selben** Auslöser wie das Home-Screen-Widget: Der
  /// Fortschritt wird an einer Stelle beobachtet und von dort an alle
  /// Empfänger verteilt. Eine zweite Beobachtungsstelle würde früher oder
  /// später auseinanderlaufen.
  ///
  /// Der Dienst räumt die Meldung selbst ab, sobald alles erledigt ist; hier
  /// wird nur zusätzlich der Nutzer-Schalter beachtet.
  Future<void> _pushStatusNotification(DailyProgress progress) async {
    final service = ref.read(notificationServiceProvider);
    // Der Tagesstand ist Beiwerk: Fehlt die Berechtigung oder antwortet der
    // Plattform-Kanal nicht, darf das die App nicht mitreißen — sie wird
    // deswegen benutzt, nicht wegen der Meldung in der Leiste.
    try {
      if (!ref.read(statusNotificationProvider)) {
        return await service.cancelDailyStatus();
      }
      await service.showDailyStatus(
        done: progress.completedCount,
        total: progress.totalCount,
        locale: ref.read(resolvedLocaleProvider),
      );
    } catch (error) {
      debugPrint('Tagesstand nicht gesetzt: $error');
    }
  }

  /// Schreibt Fortschritt, gerenderte Diagramme und Farbkacheln ins
  /// Home-Screen-Widget.
  ///
  /// Das Widget lebt außerhalb des Widget-Baums der App — seine Texte kommen
  /// daher über die aufgelöste Sprache, nicht über
  /// `AppLocalizations.of(context)` (hier oberhalb der MaterialApp gäbe es
  /// die Delegates ohnehin noch nicht).
  Future<void> _pushHomeWidgetUpdate(DailyProgress progress) async {
    // Container vor dem ersten `await` greifen: danach ist nicht garantiert,
    // dass der Element-Baum noch steht.
    final container = ProviderScope.containerOf(context);
    final service = ref.read(homeWidgetServiceProvider);

    await service.updateProgress(
      progress,
      lookupAppLocalizations(ref.read(resolvedLocaleProvider)),
    );

    final today = ref.read(todayProvider).value;
    if (today == null) return;

    await service.updateAllCharts(
      container: container,
      // Letzte 16 Wochen wie auf der Home-Seite — genug Verlauf, damit
      // auch das Matrix-Grid im Widget etwas zeigt.
      range: (start: addDays(weekStartOf(today), -7 * 15), end: today),
      progress: progress,
    );

    await service.updateColorTiles(
      await container.read(habitRepositoryProvider).habitTileData(today),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variant = ref.watch(themeVariantProvider);

    // **Ein Sender, zwei Empfänger** (siehe PLAN.md Phase 10/10.5 und 23):
    // Der heutige Fortschritt wird an genau einer Stelle beobachtet und von
    // hier an Home-Screen-Widget und Tagesstand-Meldung verteilt. Keine
    // einzelne Seite muss daran denken, nach einer Änderung nachzuziehen.
    //
    // Bewusst `todayProgressProvider`, nicht der gewählte Tag (Phase 24):
    // Widget und Leiste zeigen immer **heute**.
    ref.listen(todayProgressProvider, (previous, next) {
      _pushHomeWidgetUpdate(next);
      _pushStatusNotification(next);
    });

    // Wer den Tagesstand abschaltet, soll ihn sofort loswerden — und beim
    // Wiedereinschalten sofort zurückbekommen, ohne auf die nächste
    // Fortschritts-Änderung zu warten.
    ref.listen(statusNotificationProvider, (previous, next) {
      if (previous == next) return;
      _pushStatusNotification(ref.read(todayProgressProvider));
    });

    // Ein Sprachwechsel wirkt auch außerhalb des Widget-Baums (siehe PLAN.md
    // Phase 11.5) — beide Stellen ziehen hier gebündelt nach, damit keine
    // Einstellungs-Seite daran denken muss. Beobachtet wird die *aufgelöste*
    // Sprache: wer „System" eingestellt lässt, bekommt keinen unnötigen
    // Durchlauf.
    ref.listen(resolvedLocaleProvider, (previous, next) async {
      if (previous == next) return;

      // Titel/Text einer Notification werden beim Planen fest
      // hineingeschrieben — ohne Neuplanen erschiene eine bereits
      // eingeplante Erinnerung weiterhin in der alten Sprache. Das
      // `initialize` registriert dabei die iOS-Notification-Kategorie
      // (Snooze-Button) in der neuen Sprache neu.
      await ref.read(notificationServiceProvider).initialize(next);
      await ref.read(habitRepositoryProvider).rescheduleAllReminders();

      if (!mounted) return;
      await _pushHomeWidgetUpdate(ref.read(todayProgressProvider));
    });

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(variant.tokens(Brightness.light)),
      darkTheme: AppTheme.dark(variant.tokens(Brightness.dark)),
      themeMode: ref.watch(themeModeProvider),
      // Sprache: `null` = Systemsprache (siehe `appLocaleProvider`). Die
      // Delegates bringen zusätzlich die Material-/Cupertino-Übersetzungen
      // für Time-Picker und Dialoge mit.
      locale: ref.watch(appLocaleProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
