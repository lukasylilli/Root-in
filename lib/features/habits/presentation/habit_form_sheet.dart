import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/habit_templates.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/platform_support.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/text_prompt_dialog.dart';
import '../../../data/local/database.dart' show Habit;
import '../../../data/models/habit_goal_type.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Sentinel-Wert im Kategorie-Dropdown, der den „Neue Kategorie"-Dialog
/// öffnet, statt eine bestehende Kategorie auszuwählen.
const String _newCategorySentinel = '__new_category__';

/// Bottom Sheet zum Anlegen **und** Bearbeiten einer Gewohnheit (siehe
/// PLAN.md Phase 4.5). Ohne [existing]: Vorlage wählen oder eigene
/// Gewohnheit anlegen. Mit [existing]: Formular vorausgefüllt, „Speichern"
/// statt „Hinzufügen", zusätzlich „Löschen". Eine Datei für beide Fälle,
/// damit das Formular (Name/Kategorie/Ziel-Typ) nicht dupliziert wird.
class HabitFormSheet extends ConsumerStatefulWidget {
  const HabitFormSheet({super.key, this.existing});

  final Habit? existing;

  @override
  ConsumerState<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends ConsumerState<HabitFormSheet> {
  late final TextEditingController _nameController;
  late HabitGoalType _goalType;
  late int _targetMinutes;
  String? _category;
  TimeOfDay? _reminderTime;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _goalType = existing?.goalType ?? HabitGoalType.checkbox;
    _targetMinutes = existing?.targetMinutes ?? 10;
    _category = existing?.category;
    final minuteOfDay = existing?.reminderEnabled == true
        ? existing?.reminderMinuteOfDay
        : null;
    _reminderTime = minuteOfDay == null
        ? null
        : TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
  }

  int? get _reminderMinuteOfDay =>
      _reminderTime == null ? null : _reminderTime!.hour * 60 + _reminderTime!.minute;

  Future<void> _pickReminderTime() async {
    // Berechtigung erst anfragen, wenn der Nutzer eine Erinnerung aktiviert.
    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    if (!mounted || !granted) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickNewCategory() async {
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => TextPromptDialog(
        title: l10n.dialogNewCategoryTitle,
        confirmLabel: l10n.actionCreate,
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;

    await ref.read(habitRepositoryProvider).addCategory(name);
    setState(() => _category = name);
  }

  Future<void> _submitCustom() async {
    final name = _nameController.text.trim();
    final category = _category;
    if (name.isEmpty || category == null) return;

    final repo = ref.read(habitRepositoryProvider);
    final targetMinutes =
        _goalType == HabitGoalType.duration ? _targetMinutes : null;

    final int habitId;
    if (_isEditing) {
      habitId = widget.existing!.id;
      await repo.updateHabit(
        id: habitId,
        name: name,
        category: category,
        goalType: _goalType,
        targetMinutes: targetMinutes,
      );
    } else {
      habitId = await repo.addHabit(
        name: name,
        colorValue: AppColors.seed.toARGB32(),
        iconKey: 'task_alt',
        category: category,
        goalType: _goalType,
        targetMinutes: targetMinutes,
      );
    }
    await repo.setHabitReminder(
      habitId: habitId,
      habitName: name,
      minuteOfDay: _reminderMinuteOfDay,
    );
    if (mounted) Navigator.of(context).pop();
  }

  /// Vorlagen-Texte werden in der **aktuellen** Sprache gespeichert (siehe
  /// `core/constants/habit_templates.dart`) — ab dem Anlegen sind sie
  /// Nutzerdaten und ändern sich bei einem Sprachwechsel nicht mehr.
  Future<void> _addFromTemplate(HabitTemplate template) async {
    final l10n = AppLocalizations.of(context);
    await ref
        .read(habitRepositoryProvider)
        .addHabit(
          name: template.name(l10n),
          colorValue: AppColors.seed.toARGB32(),
          iconKey: 'task_alt',
          category: template.category(l10n),
          goalType: template.goalType,
          targetMinutes: template.targetMinutes,
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.habitDeleteTitle),
          content: Text(l10n.habitDeleteBody(widget.existing!.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    await ref.read(habitRepositoryProvider).deleteHabit(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    // Set statt Liste: garantiert, dass die aktuell ausgewählte Kategorie
    // ([_category], z. B. aus [widget.existing]) immer genau einmal in den
    // Dropdown-Items steckt — auch solange [categoriesProvider] noch lädt
    // (sonst verletzt DropdownButtonFormField sein „initialValue muss zu
    // genau einem Item passen"-Invariant und stürzt ab).
    final categoryNames =
        {
            for (final category in categoriesAsync.value ?? const [])
              category.name,
            ?_category,
          }.toList()
          ..sort();
    _category ??= categoryNames.isNotEmpty ? categoryNames.first : null;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEditing) ...[
              Text(
                l10n.habitFormChooseTemplate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final template in habitTemplates)
                    ActionChip(
                      avatar: Icon(template.icon, size: 18),
                      label: Text(template.name(l10n)),
                      onPressed: () => _addFromTemplate(template),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              _isEditing
                  ? l10n.habitFormEditTitle
                  : l10n.habitFormCustomTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.fieldName),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l10n.fieldCategory),
              items: [
                for (final name in categoryNames)
                  DropdownMenuItem(value: name, child: Text(name)),
                DropdownMenuItem(
                  value: _newCategorySentinel,
                  child: Text(l10n.categoryNew),
                ),
              ],
              onChanged: (value) {
                if (value == _newCategorySentinel) {
                  _pickNewCategory();
                } else {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<HabitGoalType>(
              segments: [
                ButtonSegment(
                  value: HabitGoalType.checkbox,
                  label: Text(l10n.goalCheckbox),
                ),
                ButtonSegment(
                  value: HabitGoalType.duration,
                  label: Text(l10n.goalDuration),
                ),
              ],
              selected: {_goalType},
              onSelectionChanged: (selection) =>
                  setState(() => _goalType = selection.first),
            ),
            if (_goalType == HabitGoalType.duration) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(l10n.goalTargetMinutes),
                  Expanded(
                    child: Slider(
                      value: _targetMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '$_targetMinutes',
                      onChanged: (value) =>
                          setState(() => _targetMinutes = value.round()),
                    ),
                  ),
                ],
              ),
            ],
            // PLAN.md Phase 26.1: Im Browser gibt es keine Erinnerungen —
            // dann fehlt hier auch der Schalter dafür. Eine gespeicherte
            // Uhrzeit bleibt dabei **unangetastet** in der Datenbank stehen:
            // Wer dieselbe Sicherung später auf Android einspielt, findet
            // seine Erinnerungen wieder (derselbe Gedanke wie Phase 25).
            if (supportsReminders) ...[
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.reminderDaily),
                subtitle: Text(
                  _reminderTime == null
                      ? l10n.reminderOff
                      : l10n.reminderAt(_reminderTime!.format(context)),
                ),
                value: _reminderTime != null,
                onChanged: (enabled) {
                  if (enabled) {
                    _pickReminderTime();
                  } else {
                    setState(() => _reminderTime = null);
                  }
                },
              ),
              if (_reminderTime != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _pickReminderTime,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(l10n.reminderChangeTime),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: _isEditing ? l10n.actionSave : l10n.actionAdd,
              onPressed: _submitCustom,
            ),
            if (_isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.habitDeleteAction),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
