import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/models/daily_progress.dart';
import '../../data/local/database.dart' show AppDatabase;
import '../../data/repositories/habit_repository.dart'
    show
        DateRange,
        HabitTileData,
        activeHabitsProvider,
        completionsInRangeProvider,
        dailyIntensityProvider;
import '../utils/streak_calculator.dart';
import 'time_service.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../utils/platform_support.dart';
import '../widgets/dashboard/dashboard_widget_builder.dart';
import '../widgets/dashboard/dashboard_widget_type.dart';
import '../widgets/progress_ring.dart';
import '../widgets/week_checklist.dart';
import 'settings_service.dart';

/// Einzige Stelle, die mit `home_widget` spricht (siehe PLAN.md Phase 10/
/// 10.7/10.6c). Schreibt den heutigen Fortschritt und rendert die fünf
/// Diagramme sowie Tagesring und Wochen-Checkliste als Bilder für die
/// jeweils eigenen Home-Screen-Widgets.
///
/// Die Schlüssel/Provider-Namen müssen mit den Kotlin-Klassen
/// (`RootInWidgetProvider.kt`, `ChartWidgetProviders.kt`) übereinstimmen.
class HomeWidgetService {
  const HomeWidgetService();

  /// Klassenname des Fortschritts-Widget-Providers.
  static const String progressProvider = 'RootInWidgetProvider';

  static const String percentKey = 'progress_percent';
  static const String subtitleKey = 'progress_subtitle';

  /// Datenschlüssel eines Diagramm-Widgets (siehe `ChartWidgetProvider.kt`,
  /// `dataKey`). Muss zur dortigen Bildung `chart_<name>` passen.
  static String chartKeyFor(DashboardWidgetType type) => 'chart_${type.name}';

  /// Schlüssel/Provider der Widget-Familien aus der Widget-Spec (10.6c).
  static const String ringKey = 'extra_ring';
  static const String ringProvider = 'RingWidgetProvider';
  static const String checklistKey = 'extra_checklist';
  static const String checklistProvider = 'ChecklistWidgetProvider';

  /// Farbkachel (Phase 10.6d). Alle Schlüssel müssen zu
  /// `ColorTileWidgetProvider.kt` passen.
  static const String colorTileProvider = 'ColorTileWidgetProvider';

  /// Katalog für die Konfigurations-Activity: welche Gewohnheiten stehen
  /// beim Platzieren einer Kachel zur Wahl (CSV der IDs).
  static const String tileHabitIdsKey = 'tile_habit_ids';

  static String tileNameKey(int habitId) => 'tile_name_$habitId';
  static String tileColorKey(int habitId) => 'tile_color_$habitId';
  static String tileStreakKey(int habitId) => 'tile_streak_$habitId';
  static String tileDoneKey(int habitId) => 'tile_done_$habitId';

  /// Schreibt Katalog und Werte aller Farbkacheln (siehe PLAN.md
  /// Phase 10.6d). Die Kachel selbst zeigt echte Views statt eines Bildes —
  /// hier fließen daher Werte, keine PNG-Pfade.
  Future<void> updateColorTiles(List<HabitTileData> tiles) async {
    // PLAN.md Phase 26.1: Startbildschirm-Widgets gibt es nur auf
    // Android/iOS. Im Browser wäre schon der Aufruf ein fehlender
    // Platform-Channel — und das Rendern der PNGs verschwendete Zeit
    // für Bilder, die niemand anzeigt.
    if (!supportsHomeScreenWidgets) return;
    await HomeWidget.saveWidgetData<String>(
      tileHabitIdsKey,
      tiles.map((tile) => tile.id).join(','),
    );
    for (final tile in tiles) {
      await HomeWidget.saveWidgetData<String>(tileNameKey(tile.id), tile.name);
      // `toSigned(32)`: ARGB-Werte wie 0xFFF2621F liegen über
      // `Int.MAX_VALUE`. Ungewandelt schickt Dart sie als 64-Bit-Wert, und
      // Android legt sie dann als `Long` ab — `getInt` auf Kotlin-Seite wirft
      // dann eine ClassCastException (am Emulator als Absturz der
      // Konfigurations-Activity aufgefallen). Als vorzeichenbehaftete
      // 32-Bit-Zahl ist es genau Androids `@ColorInt`.
      await HomeWidget.saveWidgetData<int>(
        tileColorKey(tile.id),
        tile.colorValue.toSigned(32),
      );
      await HomeWidget.saveWidgetData<int>(
        tileStreakKey(tile.id),
        tile.streak,
      );
      await HomeWidget.saveWidgetData<bool>(
        tileDoneKey(tile.id),
        tile.doneToday,
      );
    }
    await HomeWidget.updateWidget(androidName: colorTileProvider);
  }

  Future<void> updateProgress(
    DailyProgress progress,
    AppLocalizations l10n,
  ) async {
    if (!supportsHomeScreenWidgets) return;

    await HomeWidget.saveWidgetData<int>(
      percentKey,
      (progress.percent * 100).round(),
    );
    // Phase 23: Auf dem Startbildschirm zählt, was **noch fehlt** — „Noch 2
    // offen" bewegt, „3/5 erledigt" beschreibt nur. Ohne Gewohnheiten gibt es
    // nichts zu mahnen, dann bleibt die neutrale Zählung stehen.
    final open = progress.totalCount - progress.completedCount;
    await HomeWidget.saveWidgetData<String>(
      subtitleKey,
      progress.totalCount == 0
          ? l10n.homeWidgetSubtitle(0, 0)
          : open > 0
          ? l10n.homeWidgetOpen(open)
          : l10n.homeWidgetAllDone,
    );
    await HomeWidget.updateWidget(androidName: progressProvider);
  }

  /// Rendert **alle** Bild-Widgets (fünf Diagramme + Tagesring +
  /// Wochen-Checkliste) und aktualisiert die zugehörigen Provider (siehe
  /// PLAN.md Phase 10.7/10.6c). So kann der Nutzer beliebige davon auf den
  /// Startbildschirm legen — ohne dass in der App etwas gewählt werden muss.
  Future<void> updateAllCharts({
    required ProviderContainer container,
    required DateRange range,
    required DailyProgress progress,
  }) async {
    // Vor dem Warten und Rendern prüfen: Im Browser entstünden hier neun
    // PNGs, die nie jemand anzeigt.
    if (!supportsHomeScreenWidgets) return;

    // Erst die Daten für **diesen** Zeitraum abwarten: die Diagramme lesen
    // Stream-Provider, die beim ersten Zugriff noch nichts geliefert haben.
    // Ohne dieses Warten würde ein leeres Diagramm gerendert (in der Praxis
    // aufgefallen: das Matrix-Grid kam ohne eine gefüllte Zelle heraus,
    // obwohl Erledigungen vorlagen).
    await _awaitAlive(container, completionsInRangeProvider(range));
    await _awaitAlive(container, activeHabitsProvider);

    for (final type in DashboardWidgetType.values) {
      await _renderPng(
        container: container,
        key: chartKeyFor(type),
        androidProvider: type.androidWidgetProvider,
        size: const Size(320, 200),
        child: Consumer(
          builder: (context, ref, _) => buildDashboardWidget(ref, type, range),
        ),
      );
    }

    final tokens = container
        .read(themeVariantProvider)
        .tokens(Brightness.dark);
    final today = dateOnly(range.end);
    final weekStart = weekStartOf(today);

    // Auch den Wochen-Zeitraum abwarten: die Checkliste liest eine ANDERE
    // Family-Instanz von completionsInRangeProvider als die Diagramme —
    // ohne dieses Warten käme sie leer heraus (am Emulator aufgefallen:
    // Ring 25 %, Checkliste aber ohne gefüllten Tag).
    final weekRange = (start: weekStart, end: today);
    await _awaitAlive(container, completionsInRangeProvider(weekRange));

    await _renderPng(
      container: container,
      key: ringKey,
      androidProvider: ringProvider,
      size: const Size(200, 200),
      child: Center(
        child: ProgressRing(
          percent: progress.percent,
          tokens: tokens,
          diameter: 140,
          strokeWidth: 12,
        ),
      ),
    );

    await _renderPng(
      container: container,
      key: checklistKey,
      androidProvider: checklistProvider,
      size: const Size(320, 96),
      child: Consumer(
        builder: (context, ref, _) => WeekChecklist(
          weekStart: weekStart,
          today: today,
          intensities: ref.watch(
            dailyIntensityProvider((start: weekStart, end: today)),
          ),
          tokens: tokens,
        ),
      ),
    );
  }

  /// Wartet auf den ersten Wert eines Stream-Providers und **hält ihn dabei
  /// am Leben**.
  ///
  /// `container.read(provider.future)` allein genügt nicht: ohne Zuhörer
  /// verwirft Riverpod den Provider sofort wieder, bricht damit die
  /// Subscription auf den Drift-Stream ab, und das Future wird nie erfüllt —
  /// der ganze Aktualisierungslauf bliebe an dieser Stelle stehen. Genau das
  /// ist am Emulator aufgetreten: die fünf Diagramme (deren Provider die
  /// Home-Seite ohnehin beobachtet) wurden geschrieben, Tagesring und
  /// Wochen-Checkliste dahinter nie.
  Future<T> _awaitAlive<T>(
    ProviderContainer container,
    StreamProvider<T> provider,
  ) async {
    final subscription = container.listen(provider, (_, _) {});
    try {
      return await container.read(provider.future);
    } finally {
      subscription.close();
    }
  }

  /// Rendert einen Baum als PNG und stößt das zugehörige Widget an.
  /// Bewusst **ohne** `MaterialApp`/`Scaffold`: der Baum wird abseits des
  /// App-Fensters gerendert und hat daher keinen `View`-/`MediaQuery`-
  /// Vorfahren — `MaterialApp` scheitert dort. Die wenigen benötigten
  /// Inherited-Widgets werden von Hand gesetzt. Der
  /// [UncontrolledProviderScope] lässt Provider-lesende Kinder (Consumer)
  /// unverändert arbeiten.
  Future<void> _renderPng({
    required ProviderContainer container,
    required String key,
    required String androidProvider,
    required Size size,
    required Widget child,
  }) async {
    await HomeWidget.renderFlutterWidget(
      UncontrolledProviderScope(
        container: container,
        child: Directionality(
          textDirection: TextDirection.ltr,
          // Auch die Übersetzungen müssen hier von Hand gesetzt werden: die
          // gerenderten Bausteine (Diagramme, Wochen-Checkliste) lesen ihre
          // Texte über `AppLocalizations.of(context)` und fänden abseits der
          // MaterialApp sonst keine. Die Delegates laden synchron, das Bild
          // ist also im selben Frame vollständig.
          child: Localizations(
            locale: container.read(resolvedLocaleProvider),
            delegates: AppLocalizations.localizationsDelegates,
            child: MediaQuery(
              data: MediaQueryData(size: size),
              child: Theme(
                // Dunkles Theme: der Widget-Hintergrund ist dunkel.
                data: AppTheme.dark(
                  container.read(themeVariantProvider).tokens(Brightness.dark),
                ),
                child: Container(
                  width: size.width,
                  height: size.height,
                  color: const Color(0xFF161E3C),
                  padding: const EdgeInsets.all(12),
                  // Inhalte bringen feste Höhen mit (z. B. 180 px Charts);
                  // FittedBox skaliert sie in die Widget-Größe.
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: size.width - 24,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      key: key,
      logicalSize: size,
    );
    await HomeWidget.updateWidget(androidName: androidProvider);
  }
}

final homeWidgetServiceProvider = Provider<HomeWidgetService>(
  (ref) => const HomeWidgetService(),
);

/// Host-Teil der URI, die der Log-Button der Farbkachel auslöst — muss zu
/// `ColorTileWidgetProvider.TOGGLE_HOST` passen.
const String _toggleHost = 'toggle';

/// Reagiert auf den Log-Button einer Farbkachel (siehe PLAN.md Phase 10.6d).
///
/// Läuft in einem **eigenen Isolate**, das Android für den Tipp startet: es
/// gibt keinen Riverpod-Container und keinen App-Zustand (gleiche Lage wie
/// beim Snooze-Handler der Erinnerungen, siehe `notification_service.dart`).
/// Alles Nötige kommt daher aus der URI und einer frisch geöffneten
/// Datenbank-Verbindung.
///
/// Wichtig: eine **laufende** App bemerkt diesen Schreibvorgang nicht — ihre
/// Drift-Streams hängen an der Verbindung des Haupt-Isolates. Sie holt das
/// beim Zurückkehren in den Vordergrund nach (siehe `app.dart`).
@pragma('vm:entry-point')
Future<void> colorTileInteractionCallback(Uri? uri) async {
  if (uri == null || uri.host != _toggleHost) return;
  final habitId = int.tryParse(uri.queryParameters['habitId'] ?? '');
  if (habitId == null) return;

  final db = AppDatabase();
  try {
    // Dasselbe Datum wie in der App (inkl. Online-Verifikation, mit
    // Rückfall auf die Geräteuhr) — sonst könnte ein Tipp auf die Kachel
    // auf einem anderen Tag landen als derselbe Tipp in der App.
    final today = await const TimeService().today();

    final wasDone = await db.habitCompletionDao.isCompleted(habitId, today);
    await db.habitCompletionDao.setCompleted(
      habitId,
      today,
      completed: !wasDone,
    );

    final habit = await db.habitDao.habitById(habitId);
    if (habit == null) return;

    final completions = await db.habitCompletionDao.completionsForHabitSince(
      habitId,
      today.subtract(const Duration(days: 120)),
    );
    final streak = StreakCalculator.currentStreak(
      completedDates: completions.map((c) => c.date).toSet(),
      today: today,
    );

    await HomeWidget.saveWidgetData<int>(
      HomeWidgetService.tileStreakKey(habitId),
      streak,
    );
    await HomeWidget.saveWidgetData<bool>(
      HomeWidgetService.tileDoneKey(habitId),
      !wasDone,
    );
    await HomeWidget.updateWidget(
      androidName: HomeWidgetService.colorTileProvider,
    );
  } finally {
    await db.close();
  }
}
