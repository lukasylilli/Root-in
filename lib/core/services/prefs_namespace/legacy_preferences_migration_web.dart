import 'package:web/web.dart' as web;

import 'legacy_preference_ownership.dart';

/// Browser-Fassung — siehe `legacy_preferences_migration.dart`.
///
/// Übernimmt jeden alten Eintrag `flutter.<name>`, der nach
/// [isRootInLegacyEntry] zu Root-in gehört, nach `<newPrefix><name>` und
/// **entfernt** ihn danach unter dem alten Namen. Das Entfernen ist Absicht:
/// Ein alter Root-in-Wert `theme_mode = "dark"` ließe sonst Vox abstürzen,
/// das denselben Schlüssel als Zahl liest.
///
/// Alles, was nicht eindeutig Root-in gehört (Vox' Einträge, fremde Werte
/// unter Root-ins Namen wie Vox' `theme_mode = 2`), bleibt unangetastet.
/// Ein schon vorhandener neuer Eintrag wird nie überschrieben. Die Funktion
/// ist damit beliebig oft aufrufbar; nach dem ersten Lauf findet sie nichts
/// mehr.
///
/// ⚠️ Darf den Start nie verhindern: Jeder Fehler (Speicher gesperrt, etwa
/// im privaten Modus mancher Browser) wird geschluckt — dann startet Root-in
/// eben mit Standard-Einstellungen.
void migrateLegacyPreferences({required String newPrefix}) {
  const legacyPrefix = 'flutter.';
  try {
    final storage = web.window.localStorage;
    final legacyKeys = <String>[];
    for (var i = 0; i < storage.length; i++) {
      final key = storage.key(i);
      if (key != null && key.startsWith(legacyPrefix)) legacyKeys.add(key);
    }
    for (final legacyKey in legacyKeys) {
      final name = legacyKey.substring(legacyPrefix.length);
      final raw = storage.getItem(legacyKey);
      if (raw == null || !isRootInLegacyEntry(name, raw)) continue;
      final newKey = '$newPrefix$name';
      if (storage.getItem(newKey) == null) storage.setItem(newKey, raw);
      storage.removeItem(legacyKey);
    }
  } catch (_) {
    // Siehe Doku: lieber Standard-Einstellungen als kein Start.
  }
}
