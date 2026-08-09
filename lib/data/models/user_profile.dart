/// Lokal gespeichertes Nutzerprofil (siehe PLAN.md Abschnitt 3 — wird nie
/// ins Internet gesendet). Einzige Quelle für Profil-Felder.
class UserProfile {
  const UserProfile({required this.name});

  final String name;

  static const empty = UserProfile(name: '');

  UserProfile copyWith({String? name}) =>
      UserProfile(name: name ?? this.name);
}
