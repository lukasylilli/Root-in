import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/notification_service.dart';
import 'package:root_in/core/services/time_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/features/settings/presentation/reminders_page.dart';

import '../support/dispose_and_flush.dart';
import '../support/fake_notification_service.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';
import '../support/test_time_service.dart';

void main() {
  Future<(AppDatabase, FakeNotificationService, int)> pumpPage(
    WidgetTester tester, {
    int? reminderMinuteOfDay,
  }) async {
    final db = createTestDatabase();
    final notifications = FakeNotificationService();
    final habitId = await db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: 'Laufen',
        colorValue: 0xFF000000,
        category: const Value('Sport'),
        goalType: HabitGoalType.checkbox,
        reminderEnabled: Value(reminderMinuteOfDay != null),
        reminderMinuteOfDay: Value(reminderMinuteOfDay),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(notifications),
          timeServiceProvider.overrideWithValue(
            TestTimeService(DateTime(2026, 7, 21)),
          ),
        ],
        child: localizedApp(const RemindersPage()),
      ),
    );
    await tester.pumpAndSettle();
    return (db, notifications, habitId);
  }

  testWidgets('listet Gewohnheiten ohne Erinnerung als „Keine Erinnerung"', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Laufen'), findsOneWidget);
    expect(find.text('Keine Erinnerung'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('zeigt eine gesetzte Erinnerungszeit an', (tester) async {
    await pumpPage(tester, reminderMinuteOfDay: 7 * 60 + 30);

    expect(find.textContaining('7:30'), findsOneWidget);

    await disposeAndFlush(tester);
  });

  testWidgets('Abschalten entfernt Zeit und canceln die Notification', (
    tester,
  ) async {
    final (db, notifications, habitId) = await pumpPage(
      tester,
      reminderMinuteOfDay: 8 * 60,
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    final habit = (await db.habitDao.habitById(habitId))!;
    expect(habit.reminderEnabled, isFalse);
    expect(habit.reminderMinuteOfDay, isNull);
    expect(notifications.cancelled, contains(habitId));

    await disposeAndFlush(tester);
  });
}
