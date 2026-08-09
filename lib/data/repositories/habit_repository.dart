import 'dart:ui' show Locale;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/settings_service.dart' show resolvedLocaleProvider;
import '../../core/services/time_service.dart';
import '../../core/utils/achievement_evaluator.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/streak_calculator.dart';
import '../local/daos/backup_dao.dart';
import '../local/daos/category_dao.dart';
import '../local/daos/habit_completion_dao.dart';
import '../local/daos/habit_dao.dart';
import '../local/database.dart';
import '../models/backup_data.dart';
import '../models/category_breakdown.dart';
import '../models/daily_progress.dart';
import '../models/habit_goal_type.dart';
import '../models/habit_period_stats.dart';
import '../models/habit_with_day_status.dart';
import '../models/lifetime_stats.dart';
import '../models/monthly_breakdown.dart';

/// Punkte pro erledigter Gewohnheit. Gewichtung nach Schwierigkeit/Dauer ist
/// noch offen (siehe PLAN.md Abschnitt 12).
const int pointsPerCompletion = 10;

/// Alles, was eine Farbkachel auf dem Startbildschirm anzeigt (siehe PLAN.md
/// Phase 10.6d). Bewusst ein Record: die Werte werden nur einmal quer durch
/// die Widget-Schicht gereicht, ein eigenes Modell wäre Ballast.
typedef HabitTileData = ({
  int id,
  String name,
  int colorValue,
  int streak,
  bool doneToday,
});

/// Einzige Zugriffsschicht auf Habit-/Completion-Daten für Features. Screens
/// sprechen nicht direkt mit den DAOs, sondern importieren dieses Repository.
class HabitRepository {
  HabitRepository(
    this._habitDao,
    this._completionDao,
    this._categoryDao,
    this._backupDao,
    this._timeService,
    this._notificationService,
    this._currentLocale,
  );

  final HabitDao _habitDao;
  final HabitCompletionDao _completionDao;
  final CategoryDao _categoryDao;
  final BackupDao _backupDao;
  final TimeService _timeService;
  final NotificationService _notificationService;

  /// Sprache für Notification-Texte, bei jedem Planen frisch gelesen (siehe
  /// PLAN.md Phase 11). Bewusst eine Funktion statt eines festen Werts: sonst
  /// müsste das Repository bei jedem Sprachwechsel neu gebaut werden.
  final Locale Function() _currentLocale;

  /// Erstellt eine vollständige Sicherung des aktuellen Bestands (siehe
  /// PLAN.md Phase 9).
  Future<BackupData> createBackup() async {
    return BackupData(
      version: BackupData.currentVersion,
      exportedAt: await _timeService.today(),
      habits: await _backupDao.allHabits(),
      completions: await _backupDao.allCompletions(),
      categories: await _backupDao.allCategories(),
    );
  }

  /// Ersetzt den gesamten Bestand durch [data] und plant die Erinnerungen
  /// neu — sonst zeigten nach dem Wiederherstellen zwar die richtigen
  /// Uhrzeiten in der App, es käme aber keine Benachrichtigung mehr
  /// (die alten Notifications gehörten zu den gelöschten Habit-IDs).
  Future<void> restoreBackup(BackupData data) async {
    for (final habit in await _backupDao.allHabits()) {
      await _notificationService.cancelForHabit(habit.id);
    }

    await _backupDao.replaceAll(
      newHabits: data.habits,
      newCompletions: data.completions,
      newCategories: data.categories,
    );

    for (final habit in data.habits) {
      final minuteOfDay = habit.reminderMinuteOfDay;
      if (!habit.reminderEnabled || minuteOfDay == null) continue;
      await _notificationService.scheduleForHabit(
        habitId: habit.id,
        habitName: habit.name,
        minuteOfDay: minuteOfDay,
        locale: _currentLocale(),
      );
    }
  }

  Future<DateTime> today() => _timeService.today();

  Stream<List<Habit>> watchActiveHabits() => _habitDao.watchActiveHabits();

  Stream<List<Category>> watchAllCategories() =>
      _categoryDao.watchAllCategories();

  Future<void> addCategory(String name) =>
      _categoryDao.getOrCreateCategory(name);

  /// Standard-Kategorien einer frischen Installation in der gewählten Sprache
  /// (siehe PLAN.md Phase 11.5 und 21.1). Wird beim App-Start genau einmal
  /// gerufen und tut nichts, sobald irgendeine Kategorie existiert.
  Future<int> ensureDefaultCategories(List<String> names) =>
      _categoryDao.ensureDefaultCategories(names);

  /// Nachrüsten für Bestandsnutzer — ergänzt nur Fehlendes (Phase 21.1).
  Future<int> addMissingCategories(List<String> names) =>
      _categoryDao.addMissingCategories(names);

  Future<void> renameCategory(int id, String newName) =>
      _categoryDao.renameCategory(id, newName);

  Future<DeleteCategoryOutcome> deleteCategory(int id) =>
      _categoryDao.deleteCategory(id);

  Stream<List<HabitCompletion>> watchCompletionsForDate(DateTime date) =>
      _completionDao.watchCompletionsForDate(date);

  Stream<List<HabitCompletion>> watchCompletionsInRange(
    DateTime from,
    DateTime to,
  ) => _completionDao.watchCompletionsInRange(from, to);

  Stream<List<HabitCompletion>> watchAllCompletions() =>
      _completionDao.watchAllCompletions();

  Future<int> addHabit({
    required String name,
    required int colorValue,
    required String iconKey,
    required String category,
    required HabitGoalType goalType,
    int? targetMinutes,
    int timesPerWeek = 7,
  }) async {
    // Neue Kategorien-Namen (z. B. aus einer Vorlage) automatisch in der
    // Kategorien-Liste registrieren, damit sie in der Kategorien-Verwaltung
    // auftauchen, ohne dass der Nutzer sie vorher manuell anlegen muss.
    await _categoryDao.getOrCreateCategory(category);
    return _habitDao.addHabit(
      HabitsCompanion.insert(
        name: name,
        colorValue: colorValue,
        iconKey: Value(iconKey),
        category: Value(category),
        goalType: goalType,
        targetMinutes: Value(targetMinutes),
        timesPerWeek: Value(timesPerWeek),
      ),
    );
  }

  /// Bearbeitet eine bestehende Gewohnheit (siehe PLAN.md Phase 4.5).
  Future<void> updateHabit({
    required int id,
    required String name,
    required String category,
    required HabitGoalType goalType,
    int? targetMinutes,
  }) async {
    await _categoryDao.getOrCreateCategory(category);
    await _habitDao.updateHabit(
      id,
      HabitsCompanion(
        name: Value(name),
        category: Value(category),
        goalType: Value(goalType),
        targetMinutes: Value(targetMinutes),
      ),
    );
  }

  Future<void> deleteHabit(int id) async {
    await _notificationService.cancelForHabit(id);
    await _habitDao.deleteHabit(id);
  }

  /// Setzt/entfernt die tägliche Erinnerung einer Gewohnheit (siehe PLAN.md
  /// Phase 7): schreibt die Uhrzeit in die DB **und** plant/canceln die
  /// Notification an einer Stelle, damit beide nie auseinanderlaufen.
  /// [minuteOfDay] null = Erinnerung aus.
  Future<void> setHabitReminder({
    required int habitId,
    required String habitName,
    required int? minuteOfDay,
  }) async {
    await _habitDao.setReminder(habitId, minuteOfDay);
    if (minuteOfDay == null) {
      await _notificationService.cancelForHabit(habitId);
    } else {
      await _notificationService.scheduleForHabit(
        habitId: habitId,
        habitName: habitName,
        minuteOfDay: minuteOfDay,
        locale: _currentLocale(),
        streak: await currentStreakForHabit(habitId, await today()),
      );
    }
  }

  /// Plant alle aktiven Erinnerungen neu — nötig nach einem Sprachwechsel
  /// (siehe PLAN.md Phase 11.5) **und** immer dann, wenn sich die Serie
  /// geändert hat (Phase 23).
  ///
  /// Titel und Text einer Notification werden beim Planen fest
  /// hineingeschrieben. Ohne dieses Neuplanen erschiene eine schon
  /// eingeplante Erinnerung weiterhin in der alten Sprache — und mit dem
  /// Serien-Stand von vorgestern.
  Future<void> rescheduleAllReminders() async {
    final locale = _currentLocale();
    final now = await today();
    for (final habit in await _habitDao.habitsWithReminder()) {
      final minuteOfDay = habit.reminderMinuteOfDay;
      if (minuteOfDay == null) continue;
      await _notificationService.scheduleForHabit(
        habitId: habit.id,
        habitName: habit.name,
        minuteOfDay: minuteOfDay,
        locale: locale,
        streak: await currentStreakForHabit(habit.id, now),
      );
    }
  }

  Future<void> setCompletion(
    int habitId,
    DateTime date,
    bool done, {
    int? valueMinutes,
  }) {
    return _completionDao.setCompleted(
      habitId,
      date,
      completed: done,
      valueMinutes: valueMinutes,
    );
  }

  /// Werte einer Farbkachel auf dem Startbildschirm (siehe PLAN.md
  /// Phase 10.6d): je aktiver Gewohnheit Name, Farbe, aktuelle Serie und ob
  /// sie heute schon erledigt ist.
  Future<List<HabitTileData>> habitTileData(DateTime today) async {
    final habits = await _habitDao.watchActiveHabits().first;
    return [
      for (final habit in habits)
        (
          id: habit.id,
          name: habit.name,
          colorValue: habit.colorValue,
          streak: await currentStreakForHabit(habit.id, today),
          doneToday: await _completionDao.isCompleted(habit.id, today),
        ),
    ];
  }

  Future<int> currentStreakForHabit(int habitId, DateTime today) async {
    final completions = await _completionDao.completionsForHabitSince(
      habitId,
      today.subtract(const Duration(days: 120)),
    );
    final dates = completions.map((c) => c.date).toSet();
    return StreakCalculator.currentStreak(completedDates: dates, today: today);
  }
}

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HabitRepository(
    db.habitDao,
    db.habitCompletionDao,
    db.categoryDao,
    db.backupDao,
    ref.watch(timeServiceProvider),
    ref.watch(notificationServiceProvider),
    // `read` statt `watch`: die Sprache wird erst beim Planen einer
    // Erinnerung gebraucht — ein Sprachwechsel soll nicht das ganze
    // Repository (und damit alle Streams darauf) neu aufbauen.
    () => ref.read(resolvedLocaleProvider),
  );
});

final todayProvider = FutureProvider<DateTime>((ref) {
  return ref.watch(habitRepositoryProvider).today();
});

/// Alle vom Nutzer verwalteten Kategorien (siehe PLAN.md Abschnitt 5.6).
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(habitRepositoryProvider).watchAllCategories();
});

final activeHabitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchActiveHabits();
});

/// Welchen Tag die Heute-Seite zeigt — `null` heißt „heute" (siehe PLAN.md
/// Phase 24). Bewusst ein **Override** statt eines festen Datums: So springt
/// die Seite über Mitternacht von selbst weiter, solange der Nutzer nichts
/// anderes gewählt hat.
class SelectedDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void select(DateTime date) => state = dateOnly(date);

  /// Zurück auf heute — dasselbe wie „nie etwas gewählt".
  void reset() => state = null;
}

final selectedDateOverrideProvider =
    NotifierProvider<SelectedDateNotifier, DateTime?>(
      SelectedDateNotifier.new,
    );

/// **Der eine Schalter dafür, welchen Tag die Heute-Seite zeigt.** `null`,
/// solange das heutige Datum noch geladen wird.
///
/// ⚠️ Bewusst getrennt von [todayProvider]: Das Startbildschirm-Widget und
/// die Erinnerungen lesen weiterhin „heute". Sie sind eine Tagesansicht, kein
/// Archiv — ein Widget, das den 28. März 2018 zeigt, wäre ein Fehler.
final selectedDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(selectedDateOverrideProvider) ??
      ref.watch(todayProvider).value;
});

/// Erledigungen eines beliebigen Tages. Family statt fester „heute"-Variante,
/// damit Heute-Seite (gewähltes Datum) und Widget/Karte (heute) sich
/// dieselbe Rechnung teilen (PLAN.md Abschnitt 9, „Puzzling"/DRY).
final completionsForDateProvider =
    StreamProvider.family<List<HabitCompletion>, DateTime>((ref, date) {
      return ref.watch(habitRepositoryProvider).watchCompletionsForDate(date);
    });

/// Kombiniert [activeHabitsProvider] und [completionsForDateProvider] zu einer
/// Liste mit Erledigungsstatus für [date].
///
/// **Alle aktiven Gewohnheiten sind für jedes Datum eintragbar**, auch solche,
/// die es damals noch nicht gab. Die Alternative — nur Gewohnheiten ab ihrem
/// `createdAt` — würde genau den Fall unmöglich machen, um den es in Phase 24
/// geht: einen alten Bestand nachtragen.
final habitsWithStatusForDateProvider =
    Provider.family<AsyncValue<List<HabitWithDayStatus>>, DateTime>((
      ref,
      date,
    ) {
      final habitsAsync = ref.watch(activeHabitsProvider);
      final completionsAsync = ref.watch(completionsForDateProvider(date));

      if (habitsAsync.isLoading || completionsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (habitsAsync.hasError) {
        return AsyncValue.error(habitsAsync.error!, habitsAsync.stackTrace!);
      }
      if (completionsAsync.hasError) {
        return AsyncValue.error(
          completionsAsync.error!,
          completionsAsync.stackTrace!,
        );
      }

      final habits = habitsAsync.value ?? [];
      final completedIds = (completionsAsync.value ?? [])
          .map((c) => c.habitId)
          .toSet();

      return AsyncValue.data([
        for (final habit in habits)
          HabitWithDayStatus(
            habit: habit,
            isDone: completedIds.contains(habit.id),
          ),
      ]);
    });

/// Die Liste für die Heute-Seite — am **gewählten** Tag.
final selectedDayHabitsProvider =
    Provider<AsyncValue<List<HabitWithDayStatus>>>((ref) {
      final date = ref.watch(selectedDateProvider);
      if (date == null) return const AsyncValue.loading();
      return ref.watch(habitsWithStatusForDateProvider(date));
    });

/// Zeitraum für Zeitraum-basierte Provider. Record mit struktureller
/// Gleichheit, damit es als Family-Schlüssel taugt.
typedef DateRange = ({DateTime start, DateTime end});

final completionsInRangeProvider =
    StreamProvider.family<List<HabitCompletion>, DateRange>((ref, range) {
      return ref
          .watch(habitRepositoryProvider)
          .watchCompletionsInRange(range.start, range.end);
    });

/// Anzahl Erledigungen je Tag im Zeitraum (Schlüssel: Mitternacht-normali-
/// siert, Tage ohne Erledigung fehlen). Gemeinsame Zählbasis für die
/// Tages-Intensität (Matrix-Grid) und die Tages-Diagramme der Übersicht-Seite
/// — beide dürfen nicht getrennt zählen, sonst zeigen Heatmap und Linie
/// unterschiedliche Tage.
final dailyCompletionCountProvider =
    Provider.family<Map<DateTime, int>, DateRange>((ref, range) {
      final completions = ref.watch(completionsInRangeProvider(range)).value;
      if (completions == null) return const {};

      final countPerDay = <DateTime, int>{};
      for (final completion in completions) {
        countPerDay.update(completion.date, (v) => v + 1, ifAbsent: () => 1);
      }
      return countPerDay;
    });

/// Erledigungs-Intensität pro Tag (0..1) im Zeitraum — Datenquelle des
/// Matrix-Grids auf allen Seiten. Intensität = erledigte Habits am Tag
/// geteilt durch Anzahl aktiver Habits (vereinfachend: heutige Anzahl,
/// historische Änderungen der Habit-Liste werden nicht zurückgerechnet).
final dailyIntensityProvider = Provider.family<Map<DateTime, double>, DateRange>(
  (ref, range) {
    final countPerDay = ref.watch(dailyCompletionCountProvider(range));
    final habitCount = ref.watch(activeHabitsProvider).value?.length ?? 0;
    if (countPerDay.isEmpty || habitCount == 0) return const {};

    return {
      for (final entry in countPerDay.entries)
        entry.key: (entry.value / habitCount).clamp(0.0, 1.0),
    };
  },
);

/// Erledigte Tage je Gewohnheit im Zeitraum — Datenquelle der Habit×Tag-
/// Matrix auf der Übersicht-Seite (Zeile = Gewohnheit, Spalte = Tag).
final habitDaysInRangeProvider =
    Provider.family<Map<int, Set<DateTime>>, DateRange>((ref, range) {
      final completions =
          ref.watch(completionsInRangeProvider(range)).value ?? const [];

      final daysByHabit = <int, Set<DateTime>>{};
      for (final completion in completions) {
        daysByHabit
            .putIfAbsent(completion.habitId, () => <DateTime>{})
            .add(completion.date);
      }
      return daysByHabit;
    });

/// Anzahl Kalenderwochen, die [range] abdeckt (aufgerundet) — Umrechnung des
/// Wochen-Ziels „x-mal pro Woche" auf mehrwöchige Zeiträume.
int weeksInRange(DateRange range) {
  final days =
      dateOnly(range.end).difference(dateOnly(range.start)).inDays + 1;
  return days <= 0 ? 0 : (days / 7).ceil();
}

/// Kennzahlen je aktiver Gewohnheit für einen Zeitraum (siehe PLAN.md
/// Phase 16): Erledigt/Offen/Prozent beziehen sich auf [range], die beiden
/// Serien bewusst auf den gesamten Verlauf — „aktuelle Serie: 12" soll nicht
/// bei 28 gedeckelt sein, nur weil die Seite vier Wochen zeigt.
final habitPeriodStatsProvider =
    Provider.family<List<HabitPeriodStats>, DateRange>((ref, range) {
      final today = ref.watch(todayProvider).value;
      final habits = ref.watch(activeHabitsProvider).value ?? const [];
      if (today == null || habits.isEmpty) return const [];

      final doneInRange = ref.watch(habitDaysInRangeProvider(range));
      final allCompletions = ref.watch(allCompletionsProvider).value ?? const [];

      final allDaysByHabit = <int, Set<DateTime>>{};
      for (final completion in allCompletions) {
        allDaysByHabit
            .putIfAbsent(completion.habitId, () => <DateTime>{})
            .add(completion.date);
      }

      final weeks = weeksInRange(range);

      final stats = <HabitPeriodStats>[];
      for (final habit in habits) {
        final allDays = allDaysByHabit[habit.id] ?? const <DateTime>{};
        // Für die längste Serie ab der ersten Erledigung rechnen, nicht ab
        // `startDate`: bei einer nachträglich angelegten Gewohnheit lägen
        // sonst leere Tage vor der ersten Erledigung in der Auswertung.
        final firstDay = allDays.isEmpty
            ? dateOnly(habit.startDate)
            : allDays.reduce((a, b) => a.isBefore(b) ? a : b);

        stats.add(
          HabitPeriodStats(
            habitId: habit.id,
            name: habit.name,
            category: habit.category,
            doneCount: doneInRange[habit.id]?.length ?? 0,
            targetCount: habit.timesPerWeek * weeks,
            currentStreak: StreakCalculator.currentStreak(
              completedDates: allDays,
              today: today,
            ),
            longestStreak: StreakCalculator.longestStreak(
              completedDates: allDays,
              habitStartDate: firstDay,
              today: today,
            ),
          ),
        );
      }
      return stats;
    });

/// Erledigungen je Kategorie im Zeitraum — Datenquelle des
/// „Typ von Gewohnheit"-Diagramms. Habits ohne aktuelle Kategorie-Zuordnung
/// (z. B. inzwischen archiviert) werden übersprungen.
final categoryBreakdownProvider =
    Provider.family<List<CategoryBreakdown>, DateRange>((ref, range) {
      final completions = ref.watch(completionsInRangeProvider(range)).value ?? const [];
      final habits = ref.watch(activeHabitsProvider).value ?? const [];
      final categoryById = {for (final h in habits) h.id: h.category};

      final counts = <String, int>{};
      for (final completion in completions) {
        final category = categoryById[completion.habitId];
        if (category == null) continue;
        counts.update(category, (v) => v + 1, ifAbsent: () => 1);
      }

      final result = [
        for (final entry in counts.entries)
          CategoryBreakdown(category: entry.key, count: entry.value),
      ]..sort((a, b) => b.count.compareTo(a.count));
      return result;
    });

/// Durchschnittlicher Erledigungsgrad über den Zeitraum (0..1) — „wie viel
/// Prozent des Zeitraums hast du geschafft" (siehe PLAN.md Phase 8.5:
/// Monats-/Jahres-Fortschritt auf der Fortschritts-Karte). Mittelt die
/// Tages-Intensitäten aus [dailyIntensityProvider] über **alle** Tage des
/// Zeitraums, nicht nur über die mit Erledigungen — Tage ohne Aktivität
/// zählen als 0 und senken den Wert entsprechend.
final rangeProgressPercentProvider = Provider.family<double, DateRange>((
  ref,
  range,
) {
  final intensities = ref.watch(dailyIntensityProvider(range));
  final dayCount = dateOnly(range.end).difference(dateOnly(range.start)).inDays + 1;
  if (dayCount <= 0) return 0;

  final sum = intensities.values.fold<double>(0, (total, v) => total + v);
  return (sum / dayCount).clamp(0.0, 1.0);
});

/// Erledigungen je Kalendermonat im Zeitraum — Datenquelle der
/// Monatsübersicht (siehe PLAN.md Phase 5.5), aufsteigend sortiert.
final monthlyBreakdownProvider =
    Provider.family<List<MonthlyBreakdown>, DateRange>((ref, range) {
      final completions =
          ref.watch(completionsInRangeProvider(range)).value ?? const [];

      final counts = <DateTime, int>{};
      for (final completion in completions) {
        final month = DateTime(
          completion.date.year,
          completion.date.month,
        );
        counts.update(month, (v) => v + 1, ifAbsent: () => 1);
      }

      final result = [
        for (final entry in counts.entries)
          MonthlyBreakdown(month: entry.key, count: entry.value),
      ]..sort((a, b) => a.month.compareTo(b.month));
      return result;
    });

/// Prozent & Punkte eines beliebigen Tages (siehe PLAN.md Abschnitt 7).
final dayProgressProvider = Provider.family<DailyProgress, DateTime>((
  ref,
  date,
) {
  final habitsWithStatus =
      ref.watch(habitsWithStatusForDateProvider(date)).value ?? const [];
  final completed = habitsWithStatus.where((h) => h.isDone).length;

  return DailyProgress(
    completedCount: completed,
    totalCount: habitsWithStatus.length,
    points: completed * pointsPerCompletion,
  );
});

/// Prozent & Punkte für **heute**. Startbildschirm-Widget, Home-Seite und
/// Fortschritts-Karte lesen diesen — sie meinen immer den heutigen Tag, auch
/// wenn die Heute-Seite gerade ein anderes Datum zeigt (PLAN.md Phase 24).
final todayProgressProvider = Provider<DailyProgress>((ref) {
  final today = ref.watch(todayProvider).value;
  if (today == null) return DailyProgress.empty;
  return ref.watch(dayProgressProvider(today));
});

/// Prozent & Punkte für den **gewählten** Tag — die Heute-Seite.
final selectedDayProgressProvider = Provider<DailyProgress>((ref) {
  final date = ref.watch(selectedDateProvider);
  if (date == null) return DailyProgress.empty;
  return ref.watch(dayProgressProvider(date));
});

final allCompletionsProvider = StreamProvider<List<HabitCompletion>>((ref) {
  return ref.watch(habitRepositoryProvider).watchAllCompletions();
});

/// Frühestes Datum mit einer Erledigung — Startpunkt für das „gesamter
/// Verlauf"-Matrix-Grid auf der Konto-Seite. Fällt auf heute zurück, solange
/// noch keine Erledigung existiert.
final firstActivityDateProvider = Provider<DateTime?>((ref) {
  final completions = ref.watch(allCompletionsProvider).value;
  final today = ref.watch(todayProvider).value;
  if (completions == null || today == null) return null;
  if (completions.isEmpty) return today;
  return completions
      .map((c) => c.date)
      .reduce((a, b) => a.isBefore(b) ? a : b);
});

/// Lebenslange Gesamt-Statistik für die Konto-Seite (Punkte, Erledigungen,
/// längste Serie, genutzte Kategorien) — Grundlage für Achievements. Nutzt
/// dieselbe Vereinfachung wie [categoryBreakdownProvider]: Kategorie-Zuordnung
/// über die aktuelle Habit-Liste, archivierte Habits werden übersprungen.
final lifetimeStatsProvider = Provider<LifetimeStats>((ref) {
  final completions = ref.watch(allCompletionsProvider).value;
  final today = ref.watch(todayProvider).value;
  final earliestDate = ref.watch(firstActivityDateProvider);
  if (completions == null || today == null || earliestDate == null) {
    return LifetimeStats.empty;
  }

  final habits = ref.watch(activeHabitsProvider).value ?? const [];
  final categoryById = {for (final h in habits) h.id: h.category};

  final completedDates = completions.map((c) => c.date).toSet();

  final categoriesUsed = completions
      .map((c) => categoryById[c.habitId])
      .nonNulls
      .toSet()
      .length;

  return LifetimeStats(
    totalPoints: completions.length * pointsPerCompletion,
    totalCompletions: completions.length,
    longestStreakOverall: StreakCalculator.longestStreak(
      completedDates: completedDates,
      habitStartDate: earliestDate,
      today: today,
    ),
    categoriesUsed: categoriesUsed,
  );
});

/// IDs der freigeschalteten Achievements (siehe `core/constants/achievements.dart`
/// für die Definitionen, `core/utils/achievement_evaluator.dart` für die Logik).
final unlockedAchievementIdsProvider = Provider<Set<String>>((ref) {
  return AchievementEvaluator.unlockedIds(ref.watch(lifetimeStatsProvider));
});
