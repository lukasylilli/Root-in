import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/constants/app_config.dart';
import 'package:root_in/core/utils/platform_support.dart';

/// Hält die tragende Zusage aus PLAN.md Phase 27.3 fest: **Ohne Supabase-
/// Schlüssel verhält sich die App exakt wie vor Phase 27.**
///
/// Das ist kein Randfall, sondern der Normalzustand für Tests, lokale Bauten
/// und den Notfall „der Server ist weg". Wäre `supportsCloudSync` versehentlich
/// `true`, würde die App eine Anmeldung anbieten, die nirgendwohin führt — und
/// beim ersten Aufruf in einen Fehler laufen, den niemand erwartet.
///
/// ⚠️ Ein Testlauf bekommt **nie** ein `--dart-define`, deshalb sind die Werte
/// hier immer leer. Genau das macht diesen Test möglich — und genau deshalb
/// darf kein Test jemals mit dem echten Server sprechen.
void main() {
  // Ein gewöhnlicher `flutter test`-Lauf bekommt keine `--dart-define`s, die
  // Werte sind also leer. Wer sie doch mitgibt (`--dart-define-from-file=.env`),
  // soll hier keinen verwirrenden Fehlschlag bekommen — die Aussage „ohne
  // Schlüssel keine Cloud" ist dann schlicht nicht prüfbar.
  final configured = AppConfig.hasSupabaseConfig;

  group('Ohne Supabase-Schlüssel', () {
    test('sind beide Konfigurationswerte leer', () {
      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);
    }, skip: configured ? 'mit --dart-define gestartet' : null);

    test('meldet hasSupabaseConfig false', () {
      expect(AppConfig.hasSupabaseConfig, isFalse);
    }, skip: configured ? 'mit --dart-define gestartet' : null);

    test('gibt es keine Cloud — supportsCloudSync ist false', () {
      expect(supportsCloudSync, isFalse);
    }, skip: configured ? 'mit --dart-define gestartet' : null);
  });

  test('supportsCloudSync folgt der Konfiguration, nicht der Plattform', () {
    // Die übrigen Fähigkeiten hängen an `kIsWeb`; diese eine nicht. Der Test
    // hält den Unterschied fest, damit niemand sie später „vereinheitlicht".
    expect(supportsCloudSync, AppConfig.hasSupabaseConfig);
  });
}
