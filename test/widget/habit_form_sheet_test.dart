import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/notification_service.dart';
import 'package:root_in/data/local/database.dart';
import 'package:root_in/data/models/habit_goal_type.dart';
import 'package:root_in/core/services/settings_service.dart';
import 'package:root_in/features/habits/presentation/habit_form_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/dispose_and_flush.dart';
import '../support/fake_notification_service.dart';
import '../support/localized_app.dart';
import '../support/test_database.dart';

void main() {
  testWidgets(
    'Bearbeiten-Modus zeigt vorhandene Werte und kann löschen',
    (tester) async {
      final db = createTestDatabase();
      final notifications = FakeNotificationService();
      await db.categoryDao.getOrCreateCategory('Sport');
      final habitId = await db.habitDao.addHabit(
        HabitsCompanion.insert(
          name: 'Laufen',
          colorValue: 0xFF000000,
          category: const Value('Sport'),
          goalType: HabitGoalType.checkbox,
        ),
      );
      final habit = (await db.habitDao.habitById(habitId))!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationServiceProvider.overrideWithValue(notifications),
          ],
          child: localizedApp(
            Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => HabitFormSheet(existing: habit),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Laufen'), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
      expect(find.text('Speichern'), findsOneWidget);
      expect(find.text('Gewohnheit löschen'), findsOneWidget);

      await tester.tap(find.text('Gewohnheit löschen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();

      expect(await db.habitDao.habitById(habitId), isNull);
      expect(notifications.cancelled, contains(habitId));

      await disposeAndFlush(tester);
    },
  );

  testWidgets(
    'Erinnerung aktivieren speichert Uhrzeit und plant Notification',
    (tester) async {
      // Seit Phase 11 zieht das Planen einer Erinnerung die App-Sprache aus
      // den Einstellungen (für den Notification-Text) — ohne gemockte Prefs
      // liefe der Test in den `sharedPreferencesProvider`-Fehler.
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = createTestDatabase();
      final notifications = FakeNotificationService();
      await db.categoryDao.getOrCreateCategory('Sport');
      final habitId = await db.habitDao.addHabit(
        HabitsCompanion.insert(
          name: 'Laufen',
          colorValue: 0xFF000000,
          category: const Value('Sport'),
          goalType: HabitGoalType.checkbox,
        ),
      );
      final habit = (await db.habitDao.habitById(habitId))!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(db),
            notificationServiceProvider.overrideWithValue(notifications),
          ],
          child: localizedApp(
            Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => HabitFormSheet(existing: habit),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Erinnerung einschalten → Time-Picker öffnet sich → mit OK bestätigen
      // (Standard-Startzeit 8:00).
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      final saved = (await db.habitDao.habitById(habitId))!;
      expect(saved.reminderEnabled, isTrue);
      expect(saved.reminderMinuteOfDay, 8 * 60);
      expect(notifications.scheduled[habitId], 8 * 60);

      await disposeAndFlush(tester);
    },
  );
}
