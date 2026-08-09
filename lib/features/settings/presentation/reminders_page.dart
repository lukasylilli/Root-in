import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/local/database.dart' show Habit;
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Erinnerungs-Übersicht (siehe PLAN.md Phase 8.5): zeigt alle Gewohnheiten
/// mit ihrer Erinnerungszeit auf einen Blick und lässt sie hier direkt
/// ändern oder abschalten — ohne den Umweg über das Bearbeiten-Formular
/// jeder einzelnen Gewohnheit. Erreichbar über Einstellungen → Erinnerungen.
class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  static TimeOfDay? _timeOf(Habit habit) {
    if (!habit.reminderEnabled) return null;
    final minuteOfDay = habit.reminderMinuteOfDay;
    if (minuteOfDay == null) return null;
    return TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    if (!context.mounted || !granted) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOf(habit) ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;

    await ref
        .read(habitRepositoryProvider)
        .setHabitReminder(
          habitId: habit.id,
          habitName: habit.name,
          minuteOfDay: picked.hour * 60 + picked.minute,
        );
  }

  Future<void> _disable(WidgetRef ref, Habit habit) {
    return ref
        .read(habitRepositoryProvider)
        .setHabitReminder(
          habitId: habit.id,
          habitName: habit.name,
          minuteOfDay: null,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pageRemindersTitle)),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(l10n.errorGeneric('$error'))),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.remindersEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            children: [
              for (final habit in habits)
                _ReminderTile(
                  habit: habit,
                  time: _timeOf(habit),
                  onPick: () => _pickTime(context, ref, habit),
                  onDisable: () => _disable(ref, habit),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.habit,
    required this.time,
    required this.onPick,
    required this.onDisable,
  });

  final Habit habit;
  final TimeOfDay? time;
  final VoidCallback onPick;
  final VoidCallback onDisable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SwitchListTile(
      title: Text(habit.name),
      subtitle: Text(
        time == null
            ? l10n.reminderNone
            : l10n.reminderDailyAt(time!.format(context)),
      ),
      secondary: time == null
          ? null
          : IconButton(
              icon: const Icon(Icons.schedule),
              tooltip: l10n.reminderChangeTime,
              onPressed: onPick,
            ),
      value: time != null,
      onChanged: (enabled) => enabled ? onPick() : onDisable(),
    );
  }
}
