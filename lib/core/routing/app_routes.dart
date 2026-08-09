/// Einzige Quelle für Routen-Pfade der App. [app_router.dart] und
/// [main_shell.dart] importieren diese Klasse, statt Pfad-Strings erneut
/// zu schreiben.
abstract final class AppRoutes {
  static const String home = '/';
  static const String today = '/today';
  static const String view = '/view';
  static const String settings = '/settings';
  /// Übersicht-Bühne im Vollbild (siehe PLAN.md Phase 16). Bewusst eine
  /// eigene Route **außerhalb** der Shell: nur so fällt auch die
  /// Bottom-Navigation weg, deren 80 dp im Querformat direkt von der Größe der
  /// Bühne abgehen.
  static const String overviewFullscreen = '/view/overview-fullscreen';

  /// Präfix der Anleitungs-Seiten (siehe PLAN.md Phase 17). Den vollständigen
  /// Pfad je Thema baut `GuideTopic.route` daraus — die vier Themen stehen im
  /// Enum, damit sie nur an einer Stelle aufgezählt werden.
  static const String guide = '/guide';

  /// Rubrik „موارد دیگر" (siehe PLAN.md Phase 22): Ordner-Übersicht und —
  /// mit Pfad-Parameter — ein einzelner Ordner.
  ///
  /// Anders als bei den Anleitungs-Themen kann hier **kein** Enum die Routen
  /// aufzählen: Welche Ordner es gibt, steht erst im `index.json` des
  /// Repositories. Deshalb ein Parameter — und deshalb muss die Ordner-Seite
  /// den Fall „gibt es nicht mehr" verkraften.
  static const String others = '/others';
  static const String othersFolderPattern = '$others/:folderId';

  static String othersFolder(String id) => '$others/$id';

  static const String account = '/account';
  static const String categories = '/categories';
  static const String reminders = '/reminders';

  /// Erststart-Erklärung (siehe PLAN.md Phase 11.6). Wird nicht angesteuert,
  /// sondern ist beim allerersten Start die Startroute.
  static const String onboarding = '/onboarding';

  static const List<String> bottomNavOrder = [home, today, view, settings];
}
