import '../../../l10n/gen/app_localizations.dart';

/// Welche prozentuale Kennzahl die Berg-Animation auf der Home-Seite speist
/// (siehe PLAN.md Phase 8.6 — vom Nutzer in den Einstellungen wählbar).
/// Bewusst nur Prozent-Kennzahlen: die Animation stellt einen Aufstieg von
/// 0 % bis 100 % dar.
enum AscentSource {
  today,
  week,
  month,
  year;

  String label(AppLocalizations l10n) => switch (this) {
    AscentSource.today => l10n.ascentSourceToday,
    AscentSource.week => l10n.ascentSourceWeek,
    AscentSource.month => l10n.ascentSourceMonth,
    AscentSource.year => l10n.ascentSourceYear,
  };

  /// Kurzform für die Statuszeile in der Animation.
  String shortLabel(AppLocalizations l10n) => switch (this) {
    AscentSource.today => l10n.ascentShortToday,
    AscentSource.week => l10n.ascentShortWeek,
    AscentSource.month => l10n.ascentShortMonth,
    AscentSource.year => l10n.ascentShortYear,
  };
}
