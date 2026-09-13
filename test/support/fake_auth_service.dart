import 'dart:async';

import 'package:root_in/core/services/auth_service.dart';

/// Anmeldung ohne Server (PLAN.md Phase 27.5).
///
/// ⚠️ **Kein Test spricht mit dem echten Supabase-Projekt.** Tests müssen
/// ohne Netz, ohne Schlüssel und ohne fremden Zustand laufen — sonst hängen
/// sie an der Erreichbarkeit eines Servers und hinterlassen dort Datenmüll.
/// Derselbe Gedanke wie bei `RepoFetcher` (Phase 22) und
/// `FakeRepoFetcher` (Phase 17).
class FakeAuthService extends AuthService {
  FakeAuthService({
    AuthAccount? signedIn,
    this.issue,
    Set<String>? takenUsernames,
    this.availabilityCheckSeesTaken = true,
  }) : _account = signedIn,
       takenUsernames = takenUsernames ?? {};

  /// Wenn gesetzt, scheitert jeder Vorgang mit diesem Grund.
  final AuthIssue? issue;

  /// Benutzernamen, die „auf dem Server" schon jemandem gehören (PLAN.md 31.1).
  final Set<String> takenUsernames;

  /// `false` stellt den **Wettlauf** nach: Die Vorab-Frage meldet „frei",
  /// beim Schreiben ist der Name dann doch vergeben.
  final bool availabilityCheckSeesTaken;

  AuthAccount? _account;
  final _controller = StreamController<AuthAccount?>.broadcast();

  final List<String> calls = [];

  /// Der Anzeigename, wie er „auf dem Server" liegt (PLAN.md 27.6).
  String? remoteDisplayName;

  @override
  AuthAccount? get currentAccount => _account;

  @override
  Stream<AuthAccount?> watchAccount() async* {
    yield _account;
    yield* _controller.stream;
  }

  @override
  Future<bool> initialize() async => true;

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('signIn:$email');
    if (issue != null) return AuthResult.failure(issue!);
    _account = AuthAccount(id: 'u1', email: email, username: 'testkonto');
    _controller.add(_account);
    return AuthResult.success(_account!);
  }

  /// Wie der echte Dienst: **erst das Konto, dann der Name.** Scheitert der
  /// Name, bleibt das Konto bestehen — genau der Zustand aus PLAN.md 31.1.
  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    calls.add('signUp:$email/$username');
    if (issue != null) return AuthResult.failure(issue!);
    _account = AuthAccount(id: 'u1', email: email);
    _controller.add(_account);
    return claimUsername(username);
  }

  @override
  Future<AuthResult> claimUsername(String username) async {
    calls.add('claimUsername:$username');
    if (issue != null) return AuthResult.failure(issue!);
    final account = _account;
    if (account == null) {
      return const AuthResult.failure(AuthIssue.invalidCredentials);
    }
    if (takenUsernames.contains(username)) {
      return const AuthResult.failure(AuthIssue.usernameTaken);
    }
    _account = account.withUsername(username);
    return AuthResult.success(_account!);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    calls.add('isUsernameAvailable:$username');
    return !(availabilityCheckSeesTaken && takenUsernames.contains(username));
  }

  @override
  Future<String?> loadUsername() async => _account?.username;

  @override
  Future<String?> loadDisplayName() async => remoteDisplayName;

  @override
  Future<void> saveDisplayName(String name) async {
    calls.add('saveDisplayName:$name');
    remoteDisplayName = name;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _account = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
