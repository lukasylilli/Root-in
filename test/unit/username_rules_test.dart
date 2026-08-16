import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/username_rules.dart';

/// PLAN.md Phase 27.5. Die Namensregeln sind der Teil der Registrierung, der
/// **still falsch sein kann**: Ein Fehler hier wirft keine Meldung, sondern
/// höhlt die zugesagte Eindeutigkeit aus — „Ali" und „ali" wären zwei
/// Menschen. Deshalb geprüft als reine Funktion, ohne Server und ohne Netz.
void main() {
  group('normalize', () {
    test('schneidet Leerraum ab und schreibt klein', () {
      expect(UsernameRules.normalize('  Ali  '), 'ali');
    });

    test('„Ali", „ALI" und „ali" sind DERSELBE Name', () {
      // Der eigentliche Punkt. Der eindeutige Index in der Datenbank rechnet
      // mit demselben kleingeschriebenen Wert — weicht die App davon ab,
      // stimmt die Eindeutigkeit auf einer der beiden Seiten nicht.
      expect(UsernameRules.normalize('Ali'), UsernameRules.normalize('ali'));
      expect(UsernameRules.normalize(' ALI '), UsernameRules.normalize('ali'));
    });
  });

  group('validate', () {
    test('nimmt gewöhnliche Namen an', () {
      for (final name in ['ali', 'lukas', 'ali_2026', 'a-b', 'user123']) {
        expect(UsernameRules.validate(name), isNull, reason: name);
      }
    });

    test('lehnt Leeres ab', () {
      expect(UsernameRules.validate(''), UsernameIssue.empty);
      expect(UsernameRules.validate('   '), UsernameIssue.empty);
    });

    test('lehnt zu kurz und zu lang ab', () {
      expect(UsernameRules.validate('ab'), UsernameIssue.tooShort);
      expect(
        UsernameRules.validate('a' * (UsernameRules.maxLength + 1)),
        UsernameIssue.tooLong,
      );
    });

    test('lehnt Zeichen ab, die anderswo Ärger machen würden', () {
      // Leerzeichen und `@` in einem Namen, der in Adressen, Dateinamen und
      // geteilten Bildern auftaucht; fremde Schriftsysteme, weil sichtbar
      // gleiche Namen sonst verschiedene Konten wären.
      for (final name in ['ali@x', 'a li', 'ali.b', 'علی', 'ali/b', '_ali']) {
        expect(
          UsernameRules.validate(name),
          UsernameIssue.invalidCharacters,
          reason: name,
        );
      }
    });

    test('prüft den normalisierten Namen, nicht den rohen', () {
      expect(UsernameRules.validate('  ALI  '), isNull);
    });

    test('sagt nichts darüber, ob der Name FREI ist', () {
      // Festgehalten, damit niemand diese Prüfung für eine Verfügbarkeits-
      // Abfrage hält: Die Form ist in Ordnung — ob der Name vergeben ist,
      // weiß nur der Server (eindeutiger Index in supabase/schema.sql).
      expect(UsernameRules.validate('ali'), isNull);
      expect(UsernameRules.validate('ali'), isNull);
    });
  });
}
