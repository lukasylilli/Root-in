import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/notification_service.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/data/repositories/habit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_notification_service.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

/// PLAN.md Phase 23. Zwei getrennte Dinge werden geprüft:
///
/// 1. **Der Erinnerungstext nennt die Serie.** Sie steht beim *Planen* fest —
///    deshalb muss das Repository sie bei jedem Neuplanen mitgeben, sonst
///    erinnert die App mit dem Stand von vorgestern.
/// 2. **Die Tagesstand-Meldung** erscheint, solange etwas offen ist, und
///    verschwindet, sobald alles erledigt ist. Geprüft wird dafür das reine
///    Wertobjekt `DailyStatusMessage` aus dem echten Dienst — den
///    Test-Ersatz zu prüfen wäre ein Zirkelschluss, und der Plattform-Kanal
///    lässt sich im Dart-VM-Test nicht auflösen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime(2026, 7, 23);

  group('Erinnerungstext nennt die Serie', () {
    late AppDatabase db;
    late FakeNotificationService notifications;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      db = createTestDatabase();
      notifications = FakeNotificationService();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
          timeServiceProvider.overrideWithValue(TestTimeService(today)),
          notificationServiceProvider.overrideWithValue(notifications),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(db.close);
    });

    test('drei Tage am Stück landen im geplanten Text', () async {
      final repository = container.read(habitRepositoryProvider);
      final habitId = await db.habitDao.addHabit(
        HabitsCompanion.insert(
          name: 'Lesen',
          colorValue: 0xFF000000,
          category: const Value('Allgemein'),
          goalType: HabitGoalType.checkbox,
        ),
      );
      for (var back = 0; back < 3; back++) {
        await db.habitCompletionDao.setCompleted(
          habitId,
          today.subtract(Duration(days: back)),
        );
      }

      await repository.setHabitReminder(
        habitId: habitId,
        habitName: 'Lesen',
        minuteOfDay: 8 * 60,
      );

      expect(notifications.lastStreak[habitId], 3);
    });

    test('ohne Serie wird 0 übergeben — dann steht der neutrale Text', () async {
      final repository = container.read(habitRepositoryProvider);
      final habitId = await db.habitDao.addHabit(
        HabitsCompanion.insert(
          name: 'Laufen',
          colorValue: 0xFF000000,
          category: const Value('Allgemein'),
          goalType: HabitGoalType.checkbox,
        ),
      );

      await repository.setHabitReminder(
        habitId: habitId,
        habitName: 'Laufen',
        minuteOfDay: 9 * 60,
      );

      expect(notifications.lastStreak[habitId], 0);
    });

    test('Neuplanen zieht die inzwischen gewachsene Serie nach', () async {
      final repository = container.read(habitRepositoryProvider);
      final habitId = await db.habitDao.addHabit(
        HabitsCompanion.insert(
          name: 'Lesen',
          colorValue: 0xFF000000,
          category: const Value('Allgemein'),
          goalType: HabitGoalType.checkbox,
        ),
      );
      await repository.setHabitReminder(
        habitId: habitId,
        habitName: 'Lesen',
        minuteOfDay: 8 * 60,
      );
      expect(notifications.lastStreak[habitId], 0);

      // Zwei Tage erledigt — der geplante Text von vorhin ist jetzt veraltet.
      await db.habitCompletionDao.setCompleted(habitId, today);
      await db.habitCompletionDao.setCompleted(
        habitId,
        today.subtract(const Duration(days: 1)),
      );

      await repository.rescheduleAllReminders();

      expect(notifications.lastStreak[habitId], 2);
    });
  });

  group('Tagesstand-Meldung', () {
    // Geprüft wird das reine Wertobjekt: Es entscheidet, **ob** gemahnt wird
    // und **was** dort steht. Die Zustellung selbst (ongoing, Sichtbarkeit
    // auf dem Sperrbildschirm) ist deklarative Konfiguration im Dienst —
    // `FlutterLocalNotificationsPlugin` hat einen privaten Konstruktor und
    // lässt sich im Dart-VM-Test weder ersetzen noch auflösen. Diese Flags
    // gehören deshalb in den Gerätedurchgang (PLAN.md Phase 21.3).
    final l10n = testL10n();

    DailyStatusMessage? message(int done, int total) =>
        DailyStatusMessage.forProgress(done: done, total: total, l10n: l10n);

    test('offene Gewohnheiten erzeugen eine Meldung', () {
      final result = message(2, 5)!;

      expect(result.title, 'Heute: 2 von 5 erledigt');
      expect(result.body, '3 Gewohnheiten sind noch offen.');
    });

    test('eine einzelne offene Gewohnheit wird im Singular genannt', () {
      expect(message(4, 5)!.body, 'Eine Gewohnheit ist noch offen.');
    });

    test('alles erledigt räumt die Meldung ab', () {
      // `null` heißt für den Dienst: abräumen statt anzeigen.
      expect(message(5, 5), isNull);
    });

    test('ohne Gewohnheiten gibt es nichts zu mahnen', () {
      // „0 von 0 erledigt" wäre kein Ansporn, sondern Rauschen.
      expect(message(0, 0), isNull);
    });

    test('mehr erledigt als angelegt mahnt ebenfalls nicht', () {
      // Kann durch Archivieren entstehen, während der Tag schon läuft.
      expect(message(6, 5), isNull);
    });
  });

  test('der Schalter unterdrückt die Meldung', () async {
    // Der Schalter selbst ist ein Provider; `app.dart` liest ihn vor dem
    // Senden. Geprüft wird hier, dass er persistiert und standardmäßig an ist
    // — die Verdrahtung im Listener steht in app.dart daneben.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(statusNotificationProvider), isTrue);

    await container.read(statusNotificationProvider.notifier).set(false);

    expect(container.read(statusNotificationProvider), isFalse);
    expect(prefs.getBool('status_notification_enabled'), isFalse);
  });
}
