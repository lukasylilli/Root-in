/// Android/iOS-Fassung — siehe `request_persistent_storage.dart`.
///
/// Dort liegen die Daten in einem App-Verzeichnis, das kein Aufräumdienst
/// anfasst. Es gibt nichts zu erbitten, also passiert hier nichts.
Future<bool> requestPersistentStorage() async => false;
