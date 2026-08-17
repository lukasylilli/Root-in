import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../constants/app_links.dart';

/// Einzige Stelle, die mit `share_plus` spricht (siehe PLAN.md Abschnitt 5.4
/// „App teilen" und 5.5 „Fortschritt teilen"). Andere Dateien rufen nur
/// diese Methoden auf, statt selbst `SharePlus.instance.share(...)` zu
/// konstruieren.
///
/// Beide Texte tragen [appShareUrl] — **hier** ist er anklickbar, auf dem
/// geteilten Bild steht derselbe Link als QR-Code
/// (`core/widgets/share_card.dart`). Das geteilte Bild ist zugleich die
/// Werbung für die App; ohne Link führt es niemanden irgendwohin.
///
/// ⚠️ Seit Phase 27.11 ist das die **Web-Fassung**, nicht die Play-Seite:
/// Die gab es noch gar nicht, jeder geteilte QR-Code führte auf „nicht
/// gefunden". Die Begründung steht bei [appShareUrl].
class ShareService {
  const ShareService();

  Future<void> shareApp(AppLocalizations l10n) {
    return SharePlus.instance.share(
      ShareParams(text: l10n.shareAppText(appShareUrl)),
    );
  }

  /// Übergibt [imageBytes] (Screenshot der Fortschritts-Karte, siehe
  /// `core/widgets/share_card.dart`) an das System-Share-Sheet. Fortschritt
  /// wird bewusst als **Bild** geteilt (siehe PLAN.md Abschnitt 3 —
  /// „Wettkampf" per Screenshot).
  ///
  /// Seit Phase 26.1 ohne eigene temporäre Datei: `share_plus` legt auf
  /// Android/iOS selbst eine an, und im Browser gibt es keine. Damit läuft
  /// dieselbe Methode auf allen drei Plattformen.
  Future<void> shareProgressImage(
    Uint8List imageBytes,
    AppLocalizations l10n,
  ) {
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(imageBytes, mimeType: 'image/png')],
        // Ohne diesen Namen hieße das geteilte Bild nach einer zufälligen
        // Kennung — `XFile.fromData` reicht `name` außerhalb des Webs nicht
        // durch.
        fileNameOverrides: const ['root_in_fortschritt.png'],
        text: l10n.shareProgressText(appShareUrl),
        downloadFallbackEnabled: true,
      ),
    );
  }
}

final shareServiceProvider = Provider<ShareService>((ref) => const ShareService());
