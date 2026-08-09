/// Die Struktur der Rubrik „موارد دیگر" (siehe PLAN.md Phase 22) — gelesen
/// aus `content/others/<sprache>/index.json` im Inhalts-Repository.
///
/// **Warum eine Manifest-Datei und keine Ordner-Auflistung:** GitHubs
/// Rohdateien-Adresse kann keine Ordner auflisten, und die GitHub-API erlaubt
/// ohne Anmeldung nur 60 Abrufe pro Stunde und IP-Adresse — mehrere Nutzer
/// hinter derselben Mobilfunk-Adresse sähen die Rubrik zeitweise leer. Der
/// Preis ist eine Zeile Pflege je neuem Text; dafür entscheidet der Autor
/// auch über Reihenfolge und Titel.
///
/// ⚠️ **Das hier sind fremde, von Hand gepflegte Daten.** Ein Tippfehler im
/// Repository darf keine Ausnahme durch die halbe App werfen — deshalb prüft
/// [OthersManifest.fromJson] jeden Schritt und wirft eine
/// [OthersManifestException] mit **Grund-Code** statt eines Textes. Der Code
/// ist sprachneutral; die Oberfläche macht daraus eine übersetzte Meldung
/// (dieselbe Bauart wie `data/models/backup_data.dart`).
library;

/// Warum ein Manifest nicht gelesen werden konnte.
enum OthersManifestError {
  /// Die Datei ist kein gültiges JSON.
  invalidJson,

  /// Gültiges JSON, aber nicht die erwartete Form (kein Objekt, `folders`
  /// fehlt oder ist keine Liste).
  invalidFormat,

  /// Ein Ordner oder Eintrag hat ein Pflichtfeld nicht.
  incompleteEntry,
}

class OthersManifestException implements Exception {
  const OthersManifestException(this.reason, [this.detail]);

  final OthersManifestError reason;

  /// Für die Fehlersuche im Repository — landet **nicht** übersetzt in der
  /// Oberfläche, hilft dem Autor aber beim Nachschauen.
  final String? detail;

  @override
  String toString() =>
      'OthersManifestException(${reason.name}${detail == null ? '' : ': $detail'})';
}

/// Ein Text in einem Ordner.
class OthersEntry {
  const OthersEntry({required this.title, required this.filePath});

  /// Freier Text — Emoji und persische Schrift ausdrücklich erlaubt.
  final String title;

  /// Pfad der Markdown-Datei, **relativ zum Sprachordner und inklusive
  /// Ordnername** (z. B. `news/start.md`).
  ///
  /// Bewusst der volle Pfad statt „Ordner + Dateiname": So setzt die App
  /// nichts zusammen, und ein Text kann später in einen anderen Ordner
  /// ziehen, ohne dass das Schema bricht.
  final String filePath;

  factory OthersEntry.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final filePath = json['file_path'];
    if (title is! String || title.isEmpty) {
      throw const OthersManifestException(
        OthersManifestError.incompleteEntry,
        'file.title',
      );
    }
    if (filePath is! String || filePath.isEmpty) {
      throw OthersManifestException(
        OthersManifestError.incompleteEntry,
        'file_path in "$title"',
      );
    }
    return OthersEntry(title: title, filePath: filePath);
  }
}

/// Ein Ordner — in der App ein Knopf, dahinter die Liste seiner Texte.
class OthersFolder {
  const OthersFolder({
    required this.id,
    required this.title,
    required this.order,
    required this.entries,
  });

  /// Stabil, auch wenn der Titel sich ändert — er steht in der Route.
  final String id;

  final String title;

  /// Kleinere Zahl steht oben. Fehlt sie, zählt der Ordner als „ganz unten".
  final int order;

  final List<OthersEntry> entries;

  factory OthersFolder.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    if (id is! String || id.isEmpty) {
      throw const OthersManifestException(
        OthersManifestError.incompleteEntry,
        'folder.id',
      );
    }
    if (title is! String || title.isEmpty) {
      throw OthersManifestException(
        OthersManifestError.incompleteEntry,
        'title in "$id"',
      );
    }

    final rawFiles = json['files'];
    if (rawFiles != null && rawFiles is! List) {
      throw OthersManifestException(
        OthersManifestError.invalidFormat,
        'files in "$id"',
      );
    }

    return OthersFolder(
      id: id,
      title: title,
      // `order` darf fehlen — dann steht der Ordner hinten statt die ganze
      // Datei ungültig zu machen.
      order: json['order'] is int ? json['order'] as int : 1 << 30,
      entries: [
        for (final file in (rawFiles as List? ?? const []))
          if (file is Map<String, dynamic>)
            OthersEntry.fromJson(file)
          else
            throw OthersManifestException(
              OthersManifestError.invalidFormat,
              'file in "$id"',
            ),
      ],
    );
  }
}

class OthersManifest {
  const OthersManifest({required this.folders});

  /// Nach `order` sortiert; bei gleichem Wert bleibt die Reihenfolge der
  /// Datei erhalten (stabile Sortierung).
  final List<OthersFolder> folders;

  static const empty = OthersManifest(folders: []);

  factory OthersManifest.fromJson(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw const OthersManifestException(OthersManifestError.invalidFormat);
    }
    final rawFolders = decoded['folders'];
    if (rawFolders is! List) {
      throw const OthersManifestException(
        OthersManifestError.invalidFormat,
        'folders',
      );
    }

    final folders = <OthersFolder>[
      for (final folder in rawFolders)
        if (folder is Map<String, dynamic>)
          OthersFolder.fromJson(folder)
        else
          throw const OthersManifestException(
            OthersManifestError.invalidFormat,
            'folder',
          ),
    ];
    // `sort` in Dart ist nicht stabil; der Index als zweites Kriterium macht
    // sie es — sonst sprängen gleich eingeordnete Ordner bei jedem Laden.
    final indexed = folders.indexed.toList()
      ..sort((a, b) {
        final byOrder = a.$2.order.compareTo(b.$2.order);
        return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
      });

    return OthersManifest(folders: [for (final entry in indexed) entry.$2]);
  }
}
