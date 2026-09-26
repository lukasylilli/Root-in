import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/prefs_namespace/legacy_preference_ownership.dart';

/// PLAN.md 31.8 — welche alten `flutter.…`-Einträge Root-in übernimmt.
///
/// Der Fall, der den Absturz auslöste: Vox schreibt `theme_mode` als Zahl.
/// Diesen Eintrag darf Root-in weder übernehmen noch löschen.
void main() {
  test('Root-ins eigene Werte werden erkannt', () {
    expect(isRootInLegacyEntry('theme_mode', '"dark"'), isTrue);
    expect(isRootInLegacyEntry('app_language', '"persian"'), isTrue);
    expect(isRootInLegacyEntry('profile_name', '"Saleh"'), isTrue);
    expect(isRootInLegacyEntry('onboarding_seen', 'true'), isTrue);
    expect(isRootInLegacyEntry('repo_content_fa/start.md', '"# Text"'), isTrue);
    expect(
      isRootInLegacyEntry('dashboard_layout_home', '["streak","ring"]'),
      isTrue,
    );
  });

  test('Vox-Wert unter gleichem Namen bleibt bei Vox (theme_mode = 2)', () {
    expect(isRootInLegacyEntry('theme_mode', '2'), isFalse);
  });

  test('fremde Schlüssel und kaputte Werte werden nicht angefasst', () {
    expect(isRootInLegacyEntry('tts_rate', '0.5'), isFalse);
    expect(isRootInLegacyEntry('vokab_user_leitner_v1', '"{}"'), isFalse);
    expect(isRootInLegacyEntry('onboarding_seen', '"ja"'), isFalse);
    expect(isRootInLegacyEntry('theme_mode', 'kein json'), isFalse);
  });
}
