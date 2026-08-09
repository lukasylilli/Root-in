import 'dart:ui' show Locale;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/l10n/app_language.dart';
import 'package:root_in/core/services/notification_service.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/data/repositories/habit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_notification_service.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

/// Phase 11.5: Titel und Text einer Notification werden beim Planen fest
/// hineingeschrieben. Nach einem Sprachwechsel müssen die bereits geplanten
/// Erinnerungen daher neu geplant werden — sonst poppen sie weiter in der
/// alten Sprache auf.
void main() {
  late AppDatabase db;
  late FakeNotificationService notifications;
  late ProviderContainer container;

  Future<int> addHabit({required String name, int? reminderMinuteOfDay}) {
    return db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: name,
        colorValue: 0xFF000000,
        category: const Value('Sport'),
        goalType: HabitGoalType.checkbox,
        reminderEnabled: Value(reminderMinuteOfDay != null),
        reminderMinuteOfDay: Value(reminderMinuteOfDay),
      ),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = createTestDatabase();
    notifications = FakeNotificationService();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
        timeServiceProvider.overrideWithValue(
          TestTimeService(DateTime(2026, 7, 26)),
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  test('plant Erinnerungen in der neu gewählten Sprache neu', () async {
    final habitId = await addHabit(name: 'Laufen', reminderMinuteOfDay: 8 * 60);
    final repo = container.read(habitRepositoryProvider);

    await container
        .read(appLanguageProvider.notifier)
        .setLanguage(AppLanguage.english);
    await repo.rescheduleAllReminders();

    expect(notifications.scheduled[habitId], 8 * 60);
    expect(notifications.lastLocale, const Locale('en'));
  });

  test('lässt Gewohnheiten ohne Erinnerung unangetastet', () async {
    final withReminder = await addHabit(
      name: 'Laufen',
      reminderMinuteOfDay: 7 * 60,
    );
    final withoutReminder = await addHabit(name: 'Lesen');

    await container.read(habitRepositoryProvider).rescheduleAllReminders();

    expect(notifications.scheduled.keys, [withReminder]);
    expect(notifications.scheduled.containsKey(withoutReminder), isFalse);
  });

  test('überspringt archivierte Gewohnheiten', () async {
    final habitId = await addHabit(name: 'Laufen', reminderMinuteOfDay: 9 * 60);
    await db.habitDao.archiveHabit(habitId);

    await container.read(habitRepositoryProvider).rescheduleAllReminders();

    expect(notifications.scheduled, isEmpty);
  });
}
