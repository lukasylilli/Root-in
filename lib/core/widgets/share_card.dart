import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/gen/app_localizations.dart';
import '../constants/app_links.dart';
import '../l10n/app_numbers.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_tokens.dart';
import 'matrix_grid.dart';
import 'stat_column.dart';

/// Einzige Fortschritts-Karte der App (siehe PLAN.md Abschnitt 3/7 und
/// Phase 19 — Basis für den „Wettkampf" zwischen Nutzern per Bild).
///
/// Nimmt reine Werte und [AppThemeTokens] entgegen statt Provider zu lesen,
/// damit sie live angezeigt **und** offscreen für den Screenshot gerendert
/// werden kann (`share_progress_sheet.dart`). Kein Farbwert entsteht hier —
/// alles kommt aus den Tokens (Design-Token-Prinzip, PLAN.md Abschnitt 9).
///
/// **Feste Breite statt „so breit wie der Bildschirm":** Ein geteiltes Bild
/// soll auf jedem Gerät gleich aussehen. Die Karte legt sich deshalb selbst
/// auf [width] fest; die Vorschau skaliert sie über eine `FittedBox` herunter
/// (der Screenshot greift die Karte in ihrer natürlichen Größe ab und bleibt
/// dadurch scharf).
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.tokens,
    required this.profileName,
    required this.date,
    required this.percentToday,
    required this.percentMonth,
    required this.percentYear,
    required this.points,
    required this.longestStreak,
    required this.achievementsUnlocked,
    required this.achievementsTotal,
    required this.gridStart,
    required this.gridEnd,
    required this.gridIntensities,
    this.overview,
    this.width = narrowWidth,
  });

  final AppThemeTokens tokens;

  /// Name aus dem lokalen Profil. Leer = die Kopfzeile zeigt nur den Titel.
  final String profileName;

  /// Tag, für den die Karte gilt — beantwortet beim Betrachter die Frage
  /// „von wann ist das Bild?", die ein Screenshot sonst offenlässt.
  final DateTime date;

  final double percentToday;
  final double percentMonth;
  final double percentYear;
  final int points;
  final int longestStreak;
  final int achievementsUnlocked;
  final int achievementsTotal;

  /// Zeitraum + Daten des Matrix-Grids auf der Karte (siehe PLAN.md
  /// Phase 8.5). Wird immer breitenfüllend gerendert.
  final DateTime gridStart;
  final DateTime gridEnd;
  final Map<DateTime, double> gridIntensities;

  /// Der Übersicht-Block (Phase 19), fertig gebaut vom Aufrufer — in der Regel
  /// ein `OverviewBoard`. `null` heißt: Der Nutzer hat ihn im Sheet
  /// abgeschaltet, oder es gibt noch keine Gewohnheiten.
  ///
  /// Bewusst ein Widget statt sechs weiterer Datenfelder: Die Karte muss
  /// nichts über die Übersicht wissen, und das Board bleibt die **eine**
  /// Stelle, an der dieses Raster entsteht (PLAN.md Abschnitt 9).
  final Widget? overview;

  /// Innenabstand der Karte — der Aufrufer braucht ihn, um aus der Breite
  /// eines [overview]-Blocks die passende Karten-[width] zu rechnen.
  static const double padding = AppSpacing.lg;

  /// Breite der schmalen Karte ohne Übersicht-Block — hochkant, passt in
  /// jeden Chat-Verlauf.
  static const double narrowWidth = 440;

  /// Feste Breite der Karte in logischen Pixeln.
  ///
  /// Mit [overview] muss sie zur festen Breite des Blocks passen (das Board
  /// bringt seine eigene mit, siehe `OverviewMetrics.boardWidth`) — der
  /// Aufrufer rechnet `boardWidth + 2 * `[padding] und reicht das herein.
  /// Damit muss `core/` nichts aus `features/` importieren.
  final double width;

  static String _asDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: width,
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tokens.accent, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(l10n),
          const SizedBox(height: AppSpacing.md),
          _stats(l10n),
          if (overview != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle(l10n.tabOverview),
            const SizedBox(height: AppSpacing.sm),
            // Der Block ist so breit wie die Karte innen — kein FittedBox
            // nötig, die Karte hat sich bereits nach ihm gerichtet.
            overview!,
          ],
          const SizedBox(height: AppSpacing.lg),
          _sectionTitle(l10n.tabYear),
          const SizedBox(height: AppSpacing.sm),
          MatrixGrid(
            start: gridStart,
            end: gridEnd,
            intensities: gridIntensities,
            fitToWidth: true,
            tokens: tokens,
          ),
          const SizedBox(height: AppSpacing.lg),
          _footer(l10n),
        ],
      ),
    );
  }

  Widget _header(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appTitle,
                style: AppTextStyles.headline.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
              if (profileName.isNotEmpty)
                Text(
                  profileName,
                  style: AppTextStyles.body.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Text(
          _asDate(date),
          style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
        ),
      ],
    );
  }

  /// Sechs Kennzahlen. Bewusst ein [Wrap] statt einer [Row]: Auf der breiten
  /// Karte (mit Übersicht-Block) stehen sie in einer Zeile, auf der schmalen
  /// brechen sie um — eine Row lief hier um 169 px über und hätte die Zahlen
  /// im geteilten Bild abgeschnitten.
  Widget _stats(AppLocalizations l10n) {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        StatColumn(
          label: l10n.navToday,
          value: AppNumbers.percent(percentToday),
        ),
        StatColumn(
          label: l10n.tabMonth,
          value: AppNumbers.percent(percentMonth),
        ),
        StatColumn(label: l10n.tabYear, value: AppNumbers.percent(percentYear)),
        StatColumn(label: l10n.statPoints, value: '$points'),
        StatColumn(label: l10n.statLongestStreak, value: '$longestStreak'),
        StatColumn(
          label: l10n.accountAchievements,
          value: '$achievementsUnlocked/$achievementsTotal',
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
  );

  /// Fußzeile mit dem Download-Weg. Zwei Wege bewusst nebeneinander: Der
  /// QR-Code funktioniert im **Bild** (das ist nicht anklickbar), der
  /// Klartext-Hinweis daneben erklärt, wofür der Code gut ist. Anklickbar
  /// wird der Link erst im Begleittext des Share-Sheets
  /// (`core/services/share_service.dart`).
  Widget _footer(AppLocalizations l10n) {
    return Row(
      children: [
        QrImageView(
          data: appShareUrl,
          size: 96,
          padding: EdgeInsets.zero,
          backgroundColor: tokens.cardBg,
          // `eyeColor`/`dataModuleColor` statt eines Farbfilters: Der Code
          // muss auch im dunklen Theme kontrastreich bleiben.
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: tokens.textPrimary,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.shareCardDownloadTitle,
                style: AppTextStyles.body.copyWith(color: tokens.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.shareCardDownloadHint,
                style: AppTextStyles.caption.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
