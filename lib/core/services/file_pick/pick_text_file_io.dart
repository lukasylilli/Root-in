/// Nicht-Web-Fassung von `pickTextFileContent` — siehe `pick_text_file.dart`
/// für den Grund der Aufteilung.
///
/// ⚠️ **Seit PLAN.md Phase 28 ein bewusster Stub, kein toter Code.** Die App
/// gibt es nur noch im Browser; Android und iOS sind entfernt. Diese Datei
/// bleibt trotzdem stehen, weil der bedingte Import einen Nicht-Web-Zweig
/// **braucht**: `flutter test` läuft auf der Dart-VM, und die wählt genau
/// diesen hier. Ohne ihn ließe sich `backup_service.dart` gar nicht mehr
/// übersetzen — und damit kein einziger Test starten.
///
/// `null` bedeutet an dieser Stelle „der Nutzer hat abgebrochen" und wird
/// vom Aufrufer schon behandelt. Ein Wurf wäre hier falsch: Er würde in
/// Tests als Fehler durchschlagen, obwohl niemand eine Datei auswählen
/// wollte.
Future<String?> pickTextFileContent() async => null;
