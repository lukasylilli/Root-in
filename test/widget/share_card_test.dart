import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:root_in/core/constants/app_links.dart';
import 'package:root_in/core/theme/app_theme_variant.dart';
import 'package:root_in/core/widgets/matrix_grid.dart';
import 'package:root_in/core/widgets/share_card.dart';
import 'package:root_in/data/models/category_breakdown.dart';
import 'package:root_in/data/models/habit_period_stats.dart';
import 'package:root_in/features/view/overview/overview_board.dart';
import 'package:root_in/features/view/overview/overview_metrics.dart';

import '../support/localized_app.dart';

final _tokens = AppThemeVariant.green.tokens(Brightness.light);

/// Montag der ersten der vier Übersicht-Wochen bzw. „heute" darin.
final _overviewStart = DateTime(2026, 7, 6);
final _today = DateTime(2026, 7, 30);

Widget _overviewBoard() => OverviewBoard(
  start: _overviewStart,
  today: _today,
  stats: const [
    HabitPeriodStats(
      habitId: 1,
      name: 'Lesen',
      category: 'Kopf',
      doneCount: 20,
      targetCount: 28,
      currentStreak: 5,
      longestStreak: 11,
    ),
  ],
  doneDays: {
    1: {DateTime(2026, 7, 6), DateTime(2026, 7, 9)},
  },
  dailyCounts: {DateTime(2026, 7, 6): 1},
  weekCategories: const [
    [CategoryBreakdown(category: 'Kopf', count: 5)],
    [],
    [],
    [],
  ],
  tokens: _tokens,
);

Future<void> _pumpCard(WidgetTester tester, {Widget? overview}) async {
  await tester.pumpWidget(
    localizedApp(
      Scaffold(
        body: ShareCard(
          tokens: _tokens,
          profileName: 'Saleh',
          date: _today,
          percentToday: 0.75,
          percentMonth: 0.5,
          percentYear: 0.25,
          points: 340,
          longestStreak: 12,
          achievementsUnlocked: 3,
          achievementsTotal: 11,
          gridStart: DateTime(2026, 1, 1),
          gridEnd: DateTime(2026, 7, 21),
          gridIntensities: {DateTime(2026, 7, 20): 1},
          overview: overview,
          width: overview == null
              ? ShareCard.narrowWidth
              : OverviewMetrics.boardWidth + 2 * ShareCard.padding,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('zeigt Fortschritt für heute, Monat und Jahr', (tester) async {
    await _pumpCard(tester);

    expect(find.text('Heute'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Monat'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    // „Jahr" steht zweimal: als Kennzahl und als Titel über dem Matrix-Grid.
    expect(find.text('Jahr'), findsNWidgets(2));
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('zeigt Kopfzeile, Punkte, Streak und Achievements-Stand', (
    tester,
  ) async {
    await _pumpCard(tester);

    expect(find.text('Root-in'), findsOneWidget);
    // Phase 19: Name aus dem Profil und Datum machen das Bild einordenbar.
    expect(find.text('Saleh'), findsOneWidget);
    expect(find.text('30.07.2026'), findsOneWidget);
    expect(find.text('340'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3/11'), findsOneWidget);
  });

  testWidgets('enthält ein breitenfüllendes Matrix-Grid ohne Überlauf', (
    tester,
  ) async {
    await _pumpCard(tester);

    final grid = tester.widget<MatrixGrid>(find.byType(MatrixGrid));
    expect(grid.fitToWidth, isTrue);
    // Ein über die Kartenbreite hinauslaufendes Grid würde als
    // RenderFlex-Overflow gemeldet — die Karte wäre im Screenshot
    // abgeschnitten.
    expect(tester.takeException(), isNull);
  });

  testWidgets('trägt den Store-Link als QR-Code (Phase 19)', (tester) async {
    await _pumpCard(tester);

    // Ein Bild ist nicht anklickbar — der QR-Code ist der einzige Weg vom
    // geteilten Bild in den Store. Was er kodiert, lässt `QrImageView` nicht
    // auslesen (das Feld ist privat), deshalb hier zwei getrennte Prüfungen:
    // dass er auf der Karte steht, und dass die Quelle die richtige Adresse
    // liefert. Beides zusammen deckt den Weg ab.
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      playStoreUrl,
      'https://play.google.com/store/apps/details?id=com.rootin.app',
    );
    expect(find.text('Root-in laden'), findsOneWidget);
  });

  testWidgets('rendert den Übersicht-Block ohne Überlauf', (tester) async {
    // Die Karte mit Übersicht ist ~1.3 k Pixel breit — der Standard-Viewport
    // (800×600) würde überlaufen, ohne dass die Karte schuld wäre.
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpCard(tester, overview: _overviewBoard());

    expect(find.byType(OverviewBoard), findsOneWidget);
    expect(find.text('Übersicht'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Die Karte richtet sich nach der festen Breite des Boards, statt es zu
    // quetschen — sonst stünden die 28 Tages-Spalten nicht mehr im Raster.
    final card = tester.getSize(find.byType(ShareCard));
    expect(card.width, OverviewMetrics.boardWidth + 2 * ShareCard.padding);
  });

  testWidgets('ohne Übersicht bleibt die Karte schmal', (tester) async {
    await _pumpCard(tester);

    expect(find.byType(OverviewBoard), findsNothing);
    expect(tester.getSize(find.byType(ShareCard)).width, ShareCard.narrowWidth);
  });
}
