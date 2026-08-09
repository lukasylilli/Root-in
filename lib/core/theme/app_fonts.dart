/// Einzige Quelle für die App-Schriftart. `null` bedeutet: Plattform-
/// Standardschrift. Um die App-Schrift zu wechseln, hier die Font-Family
/// eintragen (z. B. nach Hinzufügen einer Google Font über `pubspec.yaml`)
/// — alle Text-Styles ziehen automatisch nach, da sie ausschließlich über
/// [AppFonts.primaryFontFamily] auf die Schrift zugreifen.
///
/// **Persisch (Phase 18): bewusst weiterhin `null`.** Android bringt die
/// arabische Schrift (Noto Naskh/Sans Arabic) als Systemschrift mit, Flutter
/// greift über den Fontconfig-Fallback darauf zu — Persisch wird also ohne
/// eigenes Asset korrekt gesetzt. Eine mitgelieferte Schrift kostete mehrere
/// hundert Kilobyte im Bundle und sähe auf jedem Gerät gleich aus, statt sich
/// dem System anzupassen. Zeigt ein Gerät stattdessen leere Kästchen, ist
/// **diese Zeile** der eine Ort, an dem eine Schrift mit arabischem
/// Zeichensatz einzutragen ist; sie gilt dann für die ganze App.
abstract final class AppFonts {
  static const String? primaryFontFamily = null;
}
