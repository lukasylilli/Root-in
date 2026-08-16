/// Nutzerkonten (PLAN.md Phase 27.5).
///
/// **Einzige** Stelle im Projekt, die `supabase_flutter` kennt — dieselbe
/// Bauart wie `notification_service.dart` oder `share_service.dart`. Die
/// Oberfläche spricht nur mit [AuthService].
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_config.dart';
import '../utils/platform_support.dart';

/// Warum ein Anmelde-Vorgang nicht geklappt hat — **sprachneutral**, wie
/// `BackupFormatException` und `UsernameIssue`.
///
/// Supabase meldet auf Englisch; die App spricht drei Sprachen. Übersetzt
/// wird in der Oberfläche, nicht hier.
enum AuthIssue {
  /// Kein Server konfiguriert — der Aufrufer hätte nicht fragen dürfen.
  notConfigured,

  /// Diese E-Mail ist schon registriert.
  emailTaken,

  /// Dieser Benutzername ist schon vergeben.
  usernameTaken,

  /// E-Mail oder Passwort stimmen nicht.
  invalidCredentials,

  /// Passwort erfüllt die Mindestanforderungen nicht.
  weakPassword,

  /// Die E-Mail-Adresse hat kein gültiges Format.
  invalidEmail,

  /// Registrierung ist auf dem Server abgeschaltet.
  signupDisabled,

  /// Zu viele Nachrichten an diese Adresse (siehe Mail-Grenze, PLAN 27.0b).
  emailRateLimited,

  /// Server nicht erreichbar — kein Netz, Projekt pausiert, Adresse gesperrt.
  offline,

  /// Alles andere. ⚠️ Muss existieren: Ein Server kann jederzeit einen Code
  /// melden, den diese Fassung der App noch nicht kennt.
  unknown,
}

/// Ordnet einen Supabase-Fehler einem [AuthIssue] zu.
///
/// ⚠️ **Es wird der `code` ausgewertet, nicht die Meldung.** Der Text ist
/// englische Prosa und kann sich jederzeit ändern; der Code ist Teil der
/// dokumentierten Schnittstelle. Wer auf `message.contains('already')` prüft,
/// baut eine Fehlerbehandlung, die beim nächsten Server-Update still bricht —
/// und still heißt hier: Der Nutzer bekommt „unbekannter Fehler" statt
/// „diese E-Mail ist schon registriert".
///
/// Als reine Funktion herausgezogen, damit sie **ohne Server prüfbar** ist —
/// derselbe Gedanke wie bei `DailyStatusMessage` (Phase 23).
AuthIssue authIssueFromCode(String? code) => switch (code) {
  'email_exists' || 'user_already_exists' => AuthIssue.emailTaken,
  'invalid_credentials' => AuthIssue.invalidCredentials,
  'weak_password' => AuthIssue.weakPassword,
  'validation_failed' => AuthIssue.invalidEmail,
  'signup_disabled' => AuthIssue.signupDisabled,
  'over_email_send_rate_limit' => AuthIssue.emailRateLimited,
  _ => AuthIssue.unknown,
};

/// Wer gerade angemeldet ist. `null` = niemand.
///
/// Bewusst ein eigener kleiner Typ statt Supabases `User`: So kennt die
/// Oberfläche das Paket nicht, und der Test braucht keinen echten `User`.
class AuthAccount {
  const AuthAccount({required this.id, required this.email, this.username});

  final String id;
  final String email;

  /// Aus `profiles.username`. `null`, solange die Profilzeile fehlt — das
  /// kommt vor, wenn die Registrierung nach dem Konto abgebrochen ist
  /// (PLAN.md 27.5). Die Oberfläche muss diesen Fall aushalten.
  final String? username;

  AuthAccount withUsername(String? name) =>
      AuthAccount(id: id, email: email, username: name);
}

/// Ergebnis eines Anmelde-Vorgangs: entweder ein Konto oder ein Grund.
class AuthResult {
  const AuthResult.success(this.account) : issue = null;
  const AuthResult.failure(this.issue) : account = null;

  final AuthAccount? account;
  final AuthIssue? issue;

  bool get isSuccess => issue == null;
}

/// Der Dienst. Alle Methoden geben [AuthResult] zurück statt zu werfen —
/// eine fehlgeschlagene Anmeldung ist ein erwarteter Verlauf, keine Ausnahme.
///
/// **Registrierung:** E-Mail + Passwort + Benutzername. Die ersten beiden
/// verwaltet Supabase in `auth.users`, der Benutzername gehört uns und liegt
/// in `profiles.username`. **Angemeldet wird mit der E-Mail** — der
/// Benutzername ist der Name *in* der App, nicht die Kennung.
///
/// ⚠️ **Ohne Konfiguration passiert hier gar nichts.** Ist `supportsCloudSync`
/// falsch, wird Supabase nie gestartet und jeder Aufruf meldet
/// [AuthIssue.notConfigured], statt in einen Fehler tief im Paket zu laufen.
/// Das ist der Normalfall in Tests und in lokalen Bauten.
class AuthService {
  const AuthService();

  /// Startet Supabase, **falls** konfiguriert. Mehrfach aufrufbar.
  ///
  /// Wird aus `main.dart` vor dem ersten Frame aufgerufen. ⚠️ Ein Fehler hier
  /// darf den Start **nicht** verhindern: Ohne Server soll die App laufen wie
  /// immer — genau deshalb fängt sie hier alles ab und meldet nur `false`.
  Future<bool> initialize() async {
    if (!supportsCloudSync) return false;
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // Heißt in neueren Fassungen `publishableKey`; `anonKey` ist derselbe
        // Wert und nur noch als veralteter Name vorhanden. In der Supabase-
        // Oberfläche kann er als „anon public" **oder** „Publishable key"
        // auftauchen — es ist derselbe Schlüssel.
        publishableKey: AppConfig.supabaseAnonKey,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get _client {
    if (!supportsCloudSync) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      // `initialize` lief nicht oder scheiterte.
      return null;
    }
  }

  /// Das gerade angemeldete Konto — **ohne** Benutzername (der kommt aus
  /// `profiles` und wird getrennt geladen, siehe 27.6).
  AuthAccount? get currentAccount {
    final user = _client?.auth.currentUser;
    if (user == null) return null;
    return AuthAccount(id: user.id, email: user.email ?? '');
  }

  /// Meldet jede Änderung des Anmelde-Zustands. Leerer Stream ohne Server.
  Stream<AuthAccount?> watchAccount() {
    final client = _client;
    if (client == null) return const Stream<AuthAccount?>.empty();
    return client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return AuthAccount(id: user.id, email: user.email ?? '');
    });
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) return const AuthResult.failure(AuthIssue.notConfigured);
    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const AuthResult.failure(AuthIssue.invalidCredentials);
      }
      return AuthResult.success(
        AuthAccount(id: user.id, email: user.email ?? ''),
      );
    } on AuthException catch (error) {
      return AuthResult.failure(authIssueFromCode(error.code));
    } catch (_) {
      // Netzfehler kommen nicht als AuthException heraus.
      return const AuthResult.failure(AuthIssue.offline);
    }
  }

  /// Legt ein Konto an und schreibt danach die Profilzeile mit dem
  /// Benutzernamen.
  ///
  /// ⚠️ **Die Reihenfolge ist nicht umkehrbar** — die Profilzeile braucht die
  /// Kennung aus `auth.users`, die es erst nach der Registrierung gibt.
  /// Daraus folgt ein Zustand, den die Oberfläche aushalten muss: Ist der
  /// **Benutzername vergeben**, existiert das Konto bereits, die Profilzeile
  /// aber nicht. Der Nutzer wählt dann einen anderen Namen, und
  /// [claimUsername] schreibt ihn nach. Das Konto darf dabei **nicht**
  /// wieder gelöscht werden: Sein Passwort ist gesetzt, seine Anmeldung
  /// gültig — nur der Name fehlt noch.
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final client = _client;
    if (client == null) return const AuthResult.failure(AuthIssue.notConfigured);
    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) return const AuthResult.failure(AuthIssue.unknown);

      final account = AuthAccount(id: user.id, email: user.email ?? '');
      final claimed = await claimUsername(username);
      return claimed.isSuccess
          ? AuthResult.success(account.withUsername(username))
          : AuthResult.failure(claimed.issue);
    } on AuthException catch (error) {
      return AuthResult.failure(authIssueFromCode(error.code));
    } catch (_) {
      return const AuthResult.failure(AuthIssue.offline);
    }
  }

  /// Schreibt den Benutzernamen in die eigene Profilzeile.
  ///
  /// ⚠️ **Der eindeutige Index in der Datenbank ist die Wahrheit**, nicht die
  /// vorherige Verfügbarkeits-Abfrage: Zwischen Frage und Schreiben kann ein
  /// anderer denselben Namen nehmen. Deshalb wird der Fehlschlag hier
  /// behandelt und nicht nur vorher zu verhindern versucht.
  Future<AuthResult> claimUsername(String username) async {
    final client = _client;
    if (client == null) return const AuthResult.failure(AuthIssue.notConfigured);
    final user = client.auth.currentUser;
    if (user == null) {
      return const AuthResult.failure(AuthIssue.invalidCredentials);
    }
    try {
      await client.from('profiles').upsert({
        'user_id': user.id,
        'username': username,
      });
      return AuthResult.success(
        AuthAccount(id: user.id, email: user.email ?? '', username: username),
      );
    } on PostgrestException catch (error) {
      // 23505 = unique_violation. Der einzige Grund, aus dem genau dieses
      // Schreiben scheitern kann, ist der belegte Name.
      return AuthResult.failure(
        error.code == '23505' ? AuthIssue.usernameTaken : AuthIssue.unknown,
      );
    } catch (_) {
      return const AuthResult.failure(AuthIssue.offline);
    }
  }

  /// Ist der Name noch frei? Reine Höflichkeit für das Formular — die
  /// verbindliche Antwort gibt erst [claimUsername].
  ///
  /// Bei Zweifeln `true`: Ein Formular, das wegen einer wackligen Verbindung
  /// „Name vergeben" behauptet, hält jemanden von seinem eigenen Namen ab.
  Future<bool> isUsernameAvailable(String username) async {
    final client = _client;
    if (client == null) return true;
    try {
      final result = await client.rpc<dynamic>(
        'username_available',
        params: {'candidate': username},
      );
      return result is bool ? result : true;
    } catch (_) {
      return true;
    }
  }

  /// Lädt den Benutzernamen aus `profiles`. `null`, wenn es keinen gibt.
  Future<String?> loadUsername() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return null;
    try {
      final row = await client
          .from('profiles')
          .select('username')
          .eq('user_id', user.id)
          .maybeSingle();
      return row?['username'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (_) {
      // Abmelden darf nie hängen bleiben. Die lokale Sitzung ist danach in
      // jedem Fall verworfen; ein Server, der nicht antwortet, ändert daran
      // nichts.
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => const AuthService());

/// Der angemeldete Zustand für die Oberfläche. `null` = niemand angemeldet.
final authAccountProvider = StreamProvider<AuthAccount?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.watchAccount();
});
