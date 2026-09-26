import 'package:shared_preferences/shared_preferences.dart';

import 'legacy_preferences_migration.dart';

/// Eigener Namensraum für Root-ins Einstellungen im Browser (PLAN.md 31.8).
///
/// **Warum:** Root-in (`lukasylilli.github.io/Root-in/`) und Vox
/// (`lukasylilli.github.io/vox/`) liegen auf **derselben Herkunft**
/// (`lukasylilli.github.io`). Der Browser-Speicher (`localStorage`) gilt je
/// Herkunft, nicht je Pfad — beide Apps sahen also denselben Speicher, und
/// `shared_preferences` legt ohne eigene Vorsilbe alles unter `flutter.…` ab.
/// Beide Apps benutzen den Schlüssel `theme_mode`: Vox als Zahl (`2` =
/// dunkel), Root-in als Text (`"dark"`). Wer Vox auf „dunkel\" stellte, dessen
/// Root-in stürzte beim Start ab (`TypeError: 2: type 'int' is not a subtype
/// of type 'String?'`, Nutzermeldung 2026-09-26) — und umgekehrt.
///
/// Mit der Vorsilbe `root_in.` gehört Root-in ein eigener Bereich; was Vox
/// schreibt, kann ihn nicht mehr berühren.
const rootInPreferencesPrefix = 'root_in.';

/// Öffnet die Einstellungen im eigenen Namensraum. Muss der **erste** Zugriff
/// auf `SharedPreferences` im Programm sein (`setPrefix` geht nur davor).
///
/// Zuvor werden Root-ins alte Einträge unter `flutter.…` einmalig in den
/// neuen Bereich übernommen, damit niemand Sprache, Namen oder Erststart-
/// Status verliert (siehe [migrateLegacyPreferences]).
///
/// Mehrfacher Aufruf ist erlaubt (`main_seed.dart` öffnet vor `main()`):
/// Alle Aufrufe teilen sich dasselbe Ergebnis, `setPrefix` läuft genau einmal.
Future<SharedPreferences> openRootInPreferences() => _opened ??= _open();

Future<SharedPreferences>? _opened;

Future<SharedPreferences> _open() async {
  migrateLegacyPreferences(newPrefix: rootInPreferencesPrefix);
  SharedPreferences.setPrefix(rootInPreferencesPrefix);
  return SharedPreferences.getInstance();
}
