import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/habit_repository.dart' show DateRange;
import '../../../l10n/gen/app_localizations.dart';
import '../../services/dashboard_layout_service.dart';
import '../../theme/app_spacing.dart';
import '../section_card.dart';
import 'dashboard_widget_builder.dart';
import 'dashboard_widget_type.dart';

/// Individualisierbarer Diagramm-/Widget-Bereich (siehe PLAN.md Phase 5.5):
/// Im Bearbeiten-Modus kann der Nutzer Widgets neu anordnen (lange drücken
/// + ziehen, [ReorderableListView]), entfernen und wieder hinzufügen.
/// Einzige Stelle mit dieser Logik — Home, View-Unterseiten und Konto
/// binden sie nur mit ihrer jeweiligen Konfiguration ein, statt sie
/// dreifach zu bauen.
class DashboardSection extends ConsumerStatefulWidget {
  const DashboardSection({
    super.key,
    required this.pageId,
    required this.availableTypes,
    required this.defaultTypes,
    required this.range,
  });

  /// Eindeutiger Schlüssel der Seite (z. B. `'home'`, `'year'`) — bestimmt,
  /// unter welchem Namen das Layout persistiert wird.
  final String pageId;

  /// Welche Widget-Typen auf dieser Seite überhaupt wählbar sind.
  final List<DashboardWidgetType> availableTypes;

  /// Voreinstellung, falls noch kein Layout gespeichert wurde (siehe
  /// `core/constants/dashboard_defaults.dart`).
  final List<DashboardWidgetType> defaultTypes;

  final DateRange range;

  @override
  ConsumerState<DashboardSection> createState() => _DashboardSectionState();
}

class _DashboardSectionState extends ConsumerState<DashboardSection> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final config = (pageId: widget.pageId, defaultTypes: widget.defaultTypes);
    final enabled = ref.watch(dashboardLayoutProvider(config));
    final notifier = ref.read(dashboardLayoutProvider(config).notifier);
    final disabled = [
      for (final type in widget.availableTypes)
        if (!enabled.contains(type)) type,
    ];
    final l10n = AppLocalizations.of(context);

    return Column(
      // stretch statt start: sonst schrumpfen die Karten auf die Breite
      // ihres Inhalts — bei kurzen Zeiträumen (z. B. Wochen-Grid mit zwei
      // Zellen) sähe die Karte schmal und unruhig neben den anderen aus.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() => _editing = !_editing),
            icon: Icon(_editing ? Icons.check : Icons.edit_outlined),
            label: Text(
              _editing ? l10n.dashboardDone : l10n.dashboardCustomize,
            ),
          ),
        ),
        if (_editing && disabled.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final type in disabled)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(type.label(l10n)),
                    onPressed: () => notifier.toggle(type),
                  ),
              ],
            ),
          ),
        if (enabled.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(l10n.dashboardEmpty),
          )
        else if (_editing)
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorderItem: notifier.reorder,
            children: [
              for (final type in enabled)
                Padding(
                  key: ValueKey(type),
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: SectionCard(
                    title: type.label(l10n),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDashboardWidget(ref, type, widget.range),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => notifier.toggle(type),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 18,
                            ),
                            label: Text(l10n.dashboardRemove),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          )
        else
          for (final type in enabled)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: SectionCard(
                title: type.label(l10n),
                child: buildDashboardWidget(ref, type, widget.range),
              ),
            ),
      ],
    );
  }
}
