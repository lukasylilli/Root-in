/// Einzige Stelle, an der Root-in Zahlen für die Anzeige formatiert (siehe
/// PLAN.md Abschnitt 9, „Puzzling"/DRY, und Phase 18 Punkt 4).
///
/// **Entschieden am 2026-08-01: westliche Ziffern (0–9) in allen Sprachen,
/// auch auf Persisch.** Persisch kennt östliche Ziffern (۱۲۳); dagegen
/// sprechen vier Dinge, die zusammen schwerer wiegen als der Gewinn an
/// Vertrautheit:
///
/// 1. **Das Übersicht-Board rechnet mit Textbreiten.** Seine 28 Spalten und
///    die Tabellendaneben liegen auf festen Koordinaten
///    (`OverviewMetrics`) — andere Ziffernbreiten verschieben dort Text in
///    die Nachbarspalte, ohne dass ein Test das meldet.
/// 2. **Die Diagramme beschriften ihre Achsen selbst.** fl_chart bekäme
///    weiterhin westliche Ziffern; die Seite sähe dann gemischt aus.
/// 3. **Die Home-Screen-Widgets folgen der Gerätesprache**, nicht der
///    App-Sprache (Android-Ressourcen, siehe PLAN.md Abschnitt 12) — App und
///    Widget würden unterschiedliche Ziffern zeigen.
/// 4. **Ziffern hatten hier schon einmal Folgen:** Die Systemsprache `fa_AT`
///    gab der JVM persische Ziffern und kippte den AAB-Build (PLAN.md
///    Lehre 4). Ein anderer Mechanismus, aber derselbe Anlass zur Vorsicht.
///
/// Rückgängig zu machen ist die Entscheidung genau hier: Eine Umstellung auf
/// `NumberFormat` mit persischem Gebietsschema betrifft nur diese Datei —
/// vorausgesetzt, niemand baut Prozentwerte wieder selbst zusammen.
library;

abstract final class AppNumbers {
  /// Anteil (0..1) als ganze Prozentzahl, z. B. `0.754` → `75%`.
  ///
  /// Ohne Leerzeichen vor dem Zeichen: Die Werte stehen fast überall in
  /// engen Kacheln und Ringen. Das Übersicht-Board setzt bewusst ein
  /// Leerzeichen — dort sind die Spaltenbreiten darauf ausgelegt.
  static String percent(double fraction) => '${(fraction * 100).round()}%';
}
