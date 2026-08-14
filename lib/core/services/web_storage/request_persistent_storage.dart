/// Bittet den Browser, den Speicher dieser Seite **dauerhaft** zu behalten
/// (PLAN.md Phase 26.8). Gibt `true` zurück, wenn er zusagt.
///
/// Hintergrund: Auf Android und iOS liegen die Daten in einem App-Verzeichnis,
/// das nur der Nutzer selbst löscht. Im Browser liegen sie im Speicher der
/// Website — und den darf der Browser bei Platzmangel aufräumen. Mit dieser
/// Bitte stuft er die Seite als „wichtig" ein und räumt sie zuletzt oder gar
/// nicht ab.
///
/// ⚠️ **Das ist eine Bitte, keine Garantie.** Browser entscheiden selbst, und
/// manche stellen die Frage gar nicht erst. Es ist eine zusätzliche Schicht —
/// die eigentliche Absicherung bleibt die Sicherung über Export/Import.
///
/// Auf Android/iOS gibt es nichts zu erbitten; dort meldet die Funktion
/// schlicht `false`, ohne etwas zu tun.
library;

export 'request_persistent_storage_io.dart'
    if (dart.library.js_interop) 'request_persistent_storage_web.dart';
