import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

import 'core/routing/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/services/cloud_auto_backup.dart';
import 'core/services/profile_cloud_sync.dart';
import 'core/services/profile_service.dart';
import 'core/services/settings_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/database.dart';
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

  @override
  Widget build(BuildContext context) {
    final variant = ref.watch(themeVariantProvider);

    // Der heutige Fortschritt wird an genau einer Stelle beobachtet.
    //
    // ⚠️ Bis Phase 28 hingen hier DREI Empfänger (Startbildschirm-Widget,
    // Tagesstand-Meldung, Cloud-Sicherung) — daher der Satz „ein Sender,
    // mehrere Empfänger" in PLAN.md Phase 10/23. Mit dem Wegfall von Android
    // und den Erinnerungen ist die Cloud-Sicherung der einzige übrig
    // gebliebene. Der Aufruf ist entprellt und schweigt ohne Konto.
    ref.listen(todayProgressProvider, (previous, next) {
      ref.read(cloudAutoBackupProvider).scheduleUpload();
    });

    // Gewohnheiten und Kategorien ändern den Bestand, ohne den heutigen
    // Fortschritt zu berühren — eine umbenannte Gewohnheit landete sonst
    // erst beim nächsten Abhaken in der Sicherung.
    ref.listen(activeHabitsProvider, (previous, next) {
      if (previous == null) return; // erster Aufbau, nichts hat sich geändert
      ref.read(cloudAutoBackupProvider).scheduleUpload();
    });

    // Anmelden gleicht den Anzeigenamen ab (PLAN.md 27.6). Die Regel für den
    // Zusammenstoß steht in `profile_cloud_sync.dart` — sie gehört an eine
    // Stelle, nicht in jede Seite, die den Namen anfasst.
    ref.listen(authAccountProvider, (previous, next) {
      if (next.value == null) return;
      unawaited(ref.read(profileCloudSyncProvider).reconcile());
    });

    // Und eine lokale Änderung wandert hoch.
    ref.listen(profileProvider, (previous, next) {
      if (previous == null || previous.name == next.name) return;
      unawaited(ref.read(profileCloudSyncProvider).pushLocalName());
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
