/// Einzige Quelle für Asset-Pfade der App (siehe PLAN.md Phase 8).
///
/// [homeAnimation] ist der Slot für die vom Nutzer gelieferte Lottie-Datei:
/// Sobald hier ein Pfad steht (und die Datei unter `assets:` in der
/// `pubspec.yaml` eingetragen ist), rendert die Home-Seite automatisch die
/// Lottie-Animation statt der eingebauten Fortschritts-Animation — es muss
/// dafür **nur diese eine Zeile** geändert werden.
abstract final class AppAssets {
  static const String? homeAnimation = null;
}
