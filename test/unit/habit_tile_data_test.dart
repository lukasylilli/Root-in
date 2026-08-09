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
import '../support/test_database.dart';
import '../support/test_time_service.dart';

/// Phase 10.6d: Werte hinter den Farbkacheln auf dem Startbildschirm.
void main() {
  final today = DateTime(2026, 7, 26);

  late AppDatabase db;
  late ProviderContainer container;

  Future<int> addHabit(String name, int colorValue) {
    return db.habitDao.addHabit(
      HabitsCompanion.insert(
        name: name,
        colorValue: colorValue,
        category: const Value('Sport'),
        goalType: HabitGoalType.checkbox,
      ),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = createTestDatabase();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        timeServiceProvider.overrideWithValue(TestTimeService(today)),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  test('liefert Name, Farbe und Erledigt-Zustand je Gewohnheit', () async {
    final laufen = await addHabit('Laufen', 0xFFF2621F);
    await addHabit('Lesen', 0xFF2E7D5B);
    await db.habitCompletionDao.setCompleted(laufen, today);

    final tiles = await container
        .read(habitRepositoryProvider)
        .habitTileData(today);

    expect(tiles, hasLength(2));

    final first = tiles.firstWhere((tile) => tile.id == laufen);
    expect(first.name, 'Laufen');
    expect(first.colorValue, 0xFFF2621F);
    expect(first.doneToday, isTrue);
    expect(first.streak, 1);

    final second = tiles.firstWhere((tile) => tile.id != laufen);
    expect(second.name, 'Lesen');
    expect(second.doneToday, isFalse);
    expect(second.streak, 0);
  });

  test('führt archivierte Gewohnheiten nicht auf', () async {
    final id = await addHabit('Laufen', 0xFF000000);
    await db.habitDao.archiveHabit(id);

    final tiles = await container
        .read(habitRepositoryProvider)
        .habitTileData(today);

    expect(tiles, isEmpty);
  });
}
