import '../local/database.dart';

/// Warum eine Sicherungsdatei nicht eingelesen werden konnte.
///
/// Bewusst ein Code statt eines fertigen Satzes: dieses Modell bleibt damit
/// sprachneutral und ohne Flutter-Abhängigkeit. Den anzeigbaren Text bildet
/// `core/services/backup_service.dart`, das die Übersetzungen ohnehin hat.
enum BackupFormatProblem {
  /// Versionsfeld fehlt oder hat den falschen Typ — vermutlich Fremd-JSON.
  notABackup,

  /// Format-Version ist neuer als die von dieser App unterstützte.
  tooNew,

  /// Struktur beschädigt (z. B. eine Liste war keine Liste).
  corrupted,
}

/// Sicherungsdatei ist nicht lesbar — siehe [problem].
class BackupFormatException implements Exception {
  const BackupFormatException(this.problem, {this.fileVersion});

  final BackupFormatProblem problem;

  /// Format-Version der Datei; nur bei [BackupFormatProblem.tooNew] gesetzt.
  final int? fileVersion;

  @override
  String toString() =>
      'BackupFormatException(${problem.name}, fileVersion: $fileVersion)';
}

/// Inhalt einer Datensicherung (siehe PLAN.md Phase 9). Reine
/// Serialisierung — kein Datei- oder Plattform-Zugriff, damit sie ohne
/// Emulator testbar bleibt; das Schreiben/Lesen übernimmt
/// `core/services/backup_service.dart`.
///
/// Die einzelnen Zeilen nutzen Drifts generierte `toJson`/`fromJson`, statt
/// jedes Feld von Hand abzuschreiben: so kann kein Feld beim Erweitern der
/// Tabellen vergessen werden.
class BackupData {
  const BackupData({
    required this.version,
    required this.exportedAt,
    required this.habits,
    required this.completions,
    required this.categories,
  });

  /// Format-Version der Sicherung. Wird beim Import geprüft, damit eine
  /// künftige, inkompatible Datei nicht stillschweigend falsch eingelesen
  /// wird.
  static const int currentVersion = 1;

  final int version;
  final DateTime exportedAt;
  final List<Habit> habits;
  final List<HabitCompletion> completions;
  final List<Category> categories;

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportedAt': exportedAt.toIso8601String(),
    'categories': [for (final category in categories) category.toJson()],
    'habits': [for (final habit in habits) habit.toJson()],
    'completions': [for (final completion in completions) completion.toJson()],
  };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    if (version is! int) {
      throw const BackupFormatException(BackupFormatProblem.notABackup);
    }
    if (version > currentVersion) {
      throw BackupFormatException(
        BackupFormatProblem.tooNew,
        fileVersion: version,
      );
    }

    return BackupData(
      version: version,
      exportedAt:
          DateTime.tryParse(json['exportedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      categories: _mapRows(json['categories'], Category.fromJson),
      habits: _mapRows(json['habits'], Habit.fromJson),
      completions: _mapRows(json['completions'], HabitCompletion.fromJson),
    );
  }

  static List<T> _mapRows<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null) return const [];
    if (raw is! List) {
      throw const BackupFormatException(BackupFormatProblem.corrupted);
    }
    return [
      for (final row in raw) fromJson(Map<String, dynamic>.from(row as Map)),
    ];
  }
}
