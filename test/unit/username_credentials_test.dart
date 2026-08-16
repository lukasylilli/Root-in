import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/username_credentials.dart';

/// PLAN.md Phase 27.5. Diese Umrechnung ist der Teil der Anmeldung, der
/// **still falsch sein kann**: Ein Fehler hier legt keine Fehlermeldung an,
/// sondern ein zweites Konto — und der Nutzer steht vor einem leeren Bestand,
/// ohne zu verstehen, warum. Deshalb prüft dieser Test sie ohne Server und
/// ohne Netz, als reine Funktion.
void main() {
  group('normalize', () {
    test('schneidet Leerraum ab und schreibt klein', () {
      expect(UsernameCredentials.normalize('  Ali  '), 'ali');
    });

    test('„Ali" und „ali" sind DERSELBE Nutzer', () {
      // Der eigentliche Punkt: Ohne diese Gleichheit gäbe es zwei Konten,
      // und der Bestand läge im falschen.
      expect(
        UsernameCredentials.emailFor('Ali'),
        UsernameCredentials.emailFor('ali'),
      );
      expect(
        UsernameCredentials.emailFor(' ALI '),
        UsernameCredentials.emailFor('ali'),
      );
    });
  });

  group('validate', () {
    test('nimmt gewöhnliche Namen an', () {
      for (final name in ['ali', 'lukas', 'ali_2026', 'a-b', 'user123']) {
        expect(UsernameCredentials.validate(name), isNull, reason: name);
      }
    });

    test('lehnt Leeres ab', () {
      expect(UsernameCredentials.validate(''), UsernameIssue.empty);
      expect(UsernameCredentials.validate('   '), UsernameIssue.empty);
    });

    test('lehnt zu kurz und zu lang ab', () {
      expect(UsernameCredentials.validate('ab'), UsernameIssue.tooShort);
      expect(
        UsernameCredentials.validate('a' * (UsernameCredentials.maxLength + 1)),
        UsernameIssue.tooLong,
      );
    });

    test('lehnt Zeichen ab, die eine Adresse zerstören würden', () {
      // Genau diese Eingaben ergäben eine ungültige Adresse — und die
      // Anmeldung scheiterte mit einer Server-Meldung auf Englisch, die
      // niemand deuten kann.
      for (final name in ['ali@x', 'a li', 'ali.b', 'علی', 'ali/b', '_ali']) {
        expect(
          UsernameCredentials.validate(name),
          UsernameIssue.invalidCharacters,
          reason: name,
        );
      }
    });

    test('prüft den normalisierten Namen, nicht den rohen', () {
      expect(UsernameCredentials.validate('  ALI  '), isNull);
    });
  });

  group('emailFor', () {
    test('hängt die reservierte Domain an', () {
      expect(UsernameCredentials.emailFor('ali'), 'ali@rootin.invalid');
    });

    test('nutzt eine Domain, die nie jemandem gehören kann', () {
      // RFC 2606 reserviert `.invalid`. Eine echte Domain hätte das reale
      // Risiko, dass eine Nachricht doch einmal bei einem Fremden landet.
      expect(UsernameCredentials.domain, endsWith('.invalid'));
    });

    test('wirft bei ungültigem Namen, statt eine kaputte Adresse zu bauen', () {
      expect(() => UsernameCredentials.emailFor('a'), throwsArgumentError);
      expect(() => UsernameCredentials.emailFor('ali@x'), throwsArgumentError);
    });
  });

  group('usernameFrom', () {
    test('führt zum Benutzernamen zurück', () {
      final email = UsernameCredentials.emailFor('ali');
      expect(UsernameCredentials.usernameFrom(email), 'ali');
    });

    test('gibt null bei fremden oder fehlenden Adressen', () {
      expect(UsernameCredentials.usernameFrom(null), isNull);
      expect(UsernameCredentials.usernameFrom('ali@gmail.com'), isNull);
      expect(UsernameCredentials.usernameFrom('@rootin.invalid'), isNull);
    });

    test('ist der Rückweg zu emailFor — für jeden gültigen Namen', () {
      for (final name in ['ali', 'lukas', 'ali_2026', 'a-b', 'user123']) {
        expect(
          UsernameCredentials.usernameFrom(UsernameCredentials.emailFor(name)),
          name,
          reason: name,
        );
      }
    });
  });
}
