import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../core/widgets/stat_column.dart';
import '../../../data/models/daily_progress.dart';
import '../../../data/models/habit_with_day_status.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../habits/presentation/habit_form_sheet.dart';

/// Die Heute-Seite zeigt seit PLAN.md Phase 24 **einen wählbaren Tag**, nicht
/// zwingend heute: Ein alter Bestand lässt sich damit nachtragen (der Nutzer
/// nannte als Beispiel den 28. März 2018).
///
/// Welcher Tag gemeint ist, steht an **einer** Stelle — `selectedDateProvider`
/// im Repository. Startbildschirm-Widget und Erinnerungen lesen weiterhin
/// „heute"; sie sind eine Tagesansicht, kein Archiv.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(selectedDayHabitsProvider);
    final progress = ref.watch(selectedDayProgressProvider);
    final date = ref.watch(selectedDateProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navToday)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const HabitFormSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(l10n.errorGeneric('$error'))),
        data: (habits) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const _DateBar(),
              const SizedBox(height: AppSpacing.sm),
              _TodayHeader(progress: progress),
              const SizedBox(height: AppSpacing.md),
              if (habits.isEmpty)
                const _EmptyState()
              else
                for (final entry in habits)
                  _HabitTile(entry: entry, date: date),
            ],
          );
        },
      ),
    );
  }
}

/// Datumszeile über dem Tagesring: einen Tag zurück, Datum antippen für die
/// Auswahl, einen Tag vor — und ein Weg zurück auf heute, sobald ein anderer
/// Tag gewählt ist.
///
/// **Die Zukunft ist gesperrt** (Vorwärts-Pfeil und Datumsauswahl enden bei
/// heute): Was noch nicht war, kann nicht erledigt sein.
class _DateBar extends ConsumerWidget {
  const _DateBar();

  static String _label(DateTime date, DateTime? today, AppLocalizations l10n) {
    if (today != null && date == today) return l10n.dateToday;
    if (today != null && date == addDays(today, -1)) return l10n.dateYesterday;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    DateTime today,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      // Weit genug zurück für einen echten Altbestand — der Nutzer nannte
      // 2018 als Beispiel.
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) {
      ref.read(selectedDateOverrideProvider.notifier).select(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final date = ref.watch(selectedDateProvider);
    final today = ref.watch(todayProvider).value;
    if (date == null || today == null) return const SizedBox.shrink();

    final notifier = ref.read(selectedDateOverrideProvider.notifier);
    final isToday = date == today;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.datePreviousDay,
          onPressed: () => notifier.select(addDays(date, -1)),
        ),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(_label(date, today, l10n)),
            onPressed: () => _pick(context, ref, date, today),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.dateNextDay,
          // Kein Tag nach heute — deshalb `null` statt eines Knopfes, der
          // nichts tut.
          onPressed: isToday ? null : () => notifier.select(addDays(date, 1)),
        ),
        if (!isToday)
          TextButton(
            onPressed: notifier.reset,
            child: Text(l10n.dateBackToToday),
          ),
      ],
    );
  }
}

/// Kopfbereich der Heute-Seite nach Spec SCREEN_13: zentrierter Tagesring
/// (Erfüllung über alle Gewohnheiten) mit Punkten/Erledigt darunter —
/// ersetzt hier den reinen Prozent-Text des [ProgressSummaryHeader]s
/// (der auf Home weiterverwendet wird).
class _TodayHeader extends ConsumerWidget {
  const _TodayHeader({required this.progress});

  final DailyProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(
      appTokensProvider(Theme.of(context).brightness),
    );
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ProgressRing(percent: progress.percent, tokens: tokens),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatColumn(
                  label: l10n.statPoints,
                  value: '${progress.points}',
                ),
                StatColumn(
                  label: l10n.statDone,
                  value: '${progress.completedCount}/${progress.totalCount}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.entry, required this.date});

  final HabitWithDayStatus entry;

  /// Der Tag, auf den das Häkchen geschrieben wird — **nicht** zwingend heute
  /// (PLAN.md Phase 24).
  final DateTime? date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: entry.isDone,
          onChanged: date == null
              ? null
              : (checked) {
                  ref
                      .read(habitRepositoryProvider)
                      .setCompletion(entry.habit.id, date!, checked ?? false);
                },
        ),
        title: Text(entry.habit.name),
        subtitle: Text(entry.habit.category),
        trailing: PopupMenuButton<_HabitAction>(
          onSelected: (action) {
            switch (action) {
              case _HabitAction.edit:
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => HabitFormSheet(existing: entry.habit),
                );
              case _HabitAction.delete:
                ref.read(habitRepositoryProvider).deleteHabit(entry.habit.id);
            }
          },
          itemBuilder: (context) {
            final l10n = AppLocalizations.of(context);
            return [
              PopupMenuItem(
                value: _HabitAction.edit,
                child: Text(l10n.actionEdit),
              ),
              PopupMenuItem(
                value: _HabitAction.delete,
                child: Text(l10n.actionDelete),
              ),
            ];
          },
        ),
      ),
    );
  }
}

enum _HabitAction { edit, delete }

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(child: Text(AppLocalizations.of(context).todayEmpty)),
    );
  }
}
