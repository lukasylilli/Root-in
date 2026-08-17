import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'profile_service.dart';

/// Gleicht den **Anzeigenamen** zwischen Gerät und Server ab
/// (PLAN.md Phase 27.6).
///
/// ⚠️ **Die Regel für den Zusammenstoß steht hier, nicht im Zufall.** Beim
/// Anmelden kann es einen lokalen Namen geben, einen auf dem Server, beide
/// oder keinen. Ohne ausdrückliche Regel gewönne, wer zuletzt schreibt — und
/// das wäre je nach Netzgeschwindigkeit mal so, mal anders:
///
/// | lokal | Server | Ergebnis |
/// |---|---|---|
/// | leer | gesetzt | Server gewinnt (das Gerät ist neu, der Name kommt zurück) |
/// | gesetzt | leer | lokal wird hochgeladen |
/// | gesetzt | gesetzt | **lokal gewinnt** und wird hochgeladen |
/// | leer | leer | nichts zu tun |
///
/// **Warum bei Gleichstand das Gerät gewinnt:** Es ist die Quelle der
/// Wahrheit (Abschnitt 3). Der Nutzer sitzt vor diesem Gerät; würde ihm ein
/// älterer Name vom Server über den gerade eingegebenen gelegt, sähe es wie
/// ein verlorener Eintrag aus. Anders herum verliert er höchstens einen
/// Namen, den er auf einem anderen Gerät gesetzt hat — sichtbar und
/// jederzeit korrigierbar.
class ProfileCloudSync {
  const ProfileCloudSync(this._ref);

  final Ref _ref;

  /// Beim Anmelden: beide Seiten vergleichen und angleichen.
  Future<void> reconcile() async {
    final auth = _ref.read(authServiceProvider);
    if (auth.currentAccount == null) return;

    final local = _ref.read(profileProvider).name.trim();
    final remote = (await auth.loadDisplayName())?.trim() ?? '';

    if (local.isEmpty && remote.isNotEmpty) {
      await _ref.read(profileProvider.notifier).setName(remote);
      return;
    }
    if (local.isNotEmpty && local != remote) {
      await auth.saveDisplayName(local);
    }
  }

  /// Nach einer lokalen Änderung: hochladen.
  Future<void> pushLocalName() async {
    final auth = _ref.read(authServiceProvider);
    if (auth.currentAccount == null) return;
    await auth.saveDisplayName(_ref.read(profileProvider).name.trim());
  }
}

final profileCloudSyncProvider = Provider<ProfileCloudSync>(
  (ref) => ProfileCloudSync(ref),
);
