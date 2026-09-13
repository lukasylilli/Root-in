/// Riverpods automatische Wiederholung — **abgeschaltet** (PLAN.md 31.2).
///
/// Seit Riverpod 3 wiederholt sich ein Provider, der eine Exception wirft,
/// von selbst: bis zu zehnmal, mit Pausen von 0,2 bis 6,4 Sekunden. Während
/// dieser rund 40 Sekunden ist sein Zustand „lädt" — nicht „Fehler".
///
/// ⚠️ **Für diese App ist das falsch.** Jede Seite, die aus dem Netz lädt, hat
/// einen eigenen Fehlerzustand mit „Erneut versuchen" (Anleitung,
/// „موارد دیگر"). Mit der automatischen Wiederholung sah ein Nutzer ohne Netz
/// stattdessen 40 Sekunden lang einen Ladekreis, während im Hintergrund still
/// zehn weitere Abrufe liefen. Gefunden hat es kein Widget-Test — die spulten
/// die Pausen mit `pumpAndSettle` in virtueller Zeit vor und sahen am Ende den
/// Knopf —, sondern die Gegenprobe des Browser-Durchgangs.
///
/// Gilt an zwei Stellen, und beide sind nötig:
/// - **am Container in `main.dart`** — für jeden Provider der App, auch für
///   einen, der später dazukommt;
/// - **an den Providern mit Fehlerzustand** (`guideDocumentProvider`,
///   `othersManifestProvider`, `othersEntryProvider`) — Tests bauen ihren
///   eigenen `ProviderScope` und sähen den Container aus `main.dart` nie.
///   `guide_page_test.dart` und `others_page_test.dart` halten es fest.
///
/// Wer für einen einzelnen Provider doch wiederholen will, gibt ihm ein
/// eigenes `retry:` — das geht dem Container vor.
Duration? noAutomaticRetry(int retryCount, Object error) => null;
