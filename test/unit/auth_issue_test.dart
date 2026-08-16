import 'package:flutter_test/flutter_test.dart';
import 'package:root_in/core/services/auth_service.dart';

/// PLAN.md Phase 27.5 — die Zuordnung Server-Fehler → sprachneutraler Grund.
///
/// Warum das einen eigenen Test verdient: Diese Zuordnung ist der Unterschied
/// zwischen „diese E-Mail ist schon registriert" und „unbekannter Fehler".
/// Sie kann **still** brechen — die App läuft weiter, nur die Auskunft an den
/// Nutzer wird nutzlos. Ein Testlauf gegen den echten Server würde das nie
/// zeigen, weil er die seltenen Fälle gar nicht erst auslöst.
///
/// Die Codes stammen aus der Supabase-Dokumentation (Auth error codes,
/// nachgelesen am 2026-08-16), nicht aus dem Gedächtnis.
void main() {
  group('authIssueFromCode', () {
    test('ordnet die dokumentierten Codes zu', () {
      expect(authIssueFromCode('email_exists'), AuthIssue.emailTaken);
      expect(authIssueFromCode('user_already_exists'), AuthIssue.emailTaken);
      expect(
        authIssueFromCode('invalid_credentials'),
        AuthIssue.invalidCredentials,
      );
      expect(authIssueFromCode('weak_password'), AuthIssue.weakPassword);
      expect(authIssueFromCode('validation_failed'), AuthIssue.invalidEmail);
      expect(authIssueFromCode('signup_disabled'), AuthIssue.signupDisabled);
      expect(
        authIssueFromCode('over_email_send_rate_limit'),
        AuthIssue.emailRateLimited,
      );
    });

    test('fällt bei unbekanntem Code auf unknown zurück', () {
      // ⚠️ Muss so sein: Der Server kann jederzeit einen Code melden, den
      // diese Fassung der App noch nicht kennt. Ein Absturz oder eine falsche
      // Zuordnung wäre schlimmer als ein ehrliches „unbekannt".
      expect(authIssueFromCode('etwas_ganz_neues'), AuthIssue.unknown);
      expect(authIssueFromCode(null), AuthIssue.unknown);
      expect(authIssueFromCode(''), AuthIssue.unknown);
    });

    test('wertet den CODE aus, nicht die englische Meldung', () {
      // Der Text ist Prosa und ändert sich ohne Ankündigung; der Code gehört
      // zur dokumentierten Schnittstelle. Wer `message.contains('already')`
      // prüft, baut etwas, das beim nächsten Server-Update still bricht.
      expect(
        authIssueFromCode('Email address already exists in the system.'),
        AuthIssue.unknown,
      );
    });
  });

  group('AuthResult', () {
    test('trennt Erfolg und Grund sauber', () {
      const ok = AuthResult.success(
        AuthAccount(id: 'u1', email: 'a@b.de', username: 'ali'),
      );
      expect(ok.isSuccess, isTrue);
      expect(ok.issue, isNull);
      expect(ok.account?.username, 'ali');

      const bad = AuthResult.failure(AuthIssue.emailTaken);
      expect(bad.isSuccess, isFalse);
      expect(bad.account, isNull);
      expect(bad.issue, AuthIssue.emailTaken);
    });

    test('ein Konto darf (vorübergehend) ohne Benutzername existieren', () {
      // Genau der Zustand nach einer Registrierung, bei der der Name schon
      // vergeben war: Konto ja, Profilzeile noch nicht. Die App muss das
      // aushalten, statt daran abzustürzen (PLAN.md 27.5).
      const account = AuthAccount(id: 'u1', email: 'a@b.de');
      expect(account.username, isNull);
      expect(account.withUsername('ali').username, 'ali');
    });
  });

  group('Ohne Konfiguration', () {
    test('meldet jeder Aufruf notConfigured statt zu werfen', () async {
      // Der Normalfall im Testlauf: keine Schlüssel, also kein Supabase.
      // ⚠️ Es darf nichts geworfen und nichts ins Netz geschickt werden.
      const service = AuthService();

      expect(await service.initialize(), isFalse);
      expect(service.currentAccount, isNull);
      expect(
        (await service.signIn(email: 'a@b.de', password: 'x')).issue,
        AuthIssue.notConfigured,
      );
      expect(
        (await service.signUp(
          email: 'a@b.de',
          password: 'x',
          username: 'ali',
        )).issue,
        AuthIssue.notConfigured,
      );
      expect(await service.loadUsername(), isNull);
      await service.signOut(); // darf nicht werfen
    });

    test('haelt einen Namen fuer frei, statt ihn zu blockieren', () async {
      // Bei Zweifeln „frei": Ein Formular, das wegen fehlender Verbindung
      // „Name vergeben" behauptet, hält jemanden von seinem eigenen Namen ab.
      const service = AuthService();
      expect(await service.isUsernameAvailable('ali'), isTrue);
    });
  });
}
