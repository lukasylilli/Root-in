import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cloud_backup_service.dart';

/// Sichert den Bestand **von selbst** auf den Server (PLAN.md Phase 27.7) —
/// der Nutzer soll nicht daran denken müssen.
///
/// ⚠️ **Entprellt, und zwar großzügig.** Ohne Verzögerung löste jedes
/// Abhaken einen vollständigen Upload aus: Wer morgens acht Gewohnheiten
/// abhakt, schickte achtmal den ganzen Bestand. Gesammelt wird deshalb, und
/// erst nach [_delay] Ruhe geht **eine** Sicherung hinaus.
///
/// ⚠️ **Scheitern bleibt folgenlos und stumm.** Kein Netz, Projekt pausiert,
/// Adresse gesperrt — es gibt keine Fehlermeldung und keinen Wiederholungs-
/// Sturm. Die nächste Änderung versucht es ohnehin erneut, und der lokale
/// Bestand ist zu keinem Zeitpunkt in Gefahr. Eine automatische Sicherung,
/// die den Nutzer mit Fehlern behelligt, wäre schlimmer als keine.
class CloudAutoBackup {
  CloudAutoBackup(this._ref);

  final Ref _ref;
  Timer? _timer;

  /// Lang genug, dass eine Morgenrunde als **ein** Upload herausgeht, kurz
  /// genug, dass man die App danach schließen kann.
  static const Duration _delay = Duration(seconds: 20);

  /// Meldet eine Änderung. Mehrere kurz hintereinander ergeben eine Sicherung.
  void scheduleUpload() {
    _timer?.cancel();
    _timer = Timer(_delay, () {
      // Kein `await`: Der Aufrufer ist ein Provider-Listener, der nicht auf
      // das Netz warten darf.
      unawaited(_ref.read(cloudBackupServiceProvider).upload());
    });
  }

  void dispose() => _timer?.cancel();
}

final cloudAutoBackupProvider = Provider<CloudAutoBackup>((ref) {
  final auto = CloudAutoBackup(ref);
  ref.onDispose(auto.dispose);
  return auto;
});
