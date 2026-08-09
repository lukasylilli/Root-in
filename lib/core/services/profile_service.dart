import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';
import 'settings_service.dart';

/// Persistiert das lokale Nutzerprofil (aktuell: Name). Einzige Stelle, die
/// `shared_preferences` für Profil-Daten anfasst — die Konto-Seite ändert
/// nur [profileProvider], nie direkt Prefs. Bleibt rein lokal (siehe
/// PLAN.md Abschnitt 3).
class ProfileService {
  const ProfileService(this._prefs);

  final SharedPreferences _prefs;

  static const _nameKey = 'profile_name';

  UserProfile loadProfile() {
    return UserProfile(name: _prefs.getString(_nameKey) ?? '');
  }

  Future<void> saveProfile(UserProfile profile) {
    return _prefs.setString(_nameKey, profile.name);
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(sharedPreferencesProvider));
});

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() => ref.watch(profileServiceProvider).loadProfile();

  Future<void> setName(String name) async {
    state = state.copyWith(name: name);
    await ref.read(profileServiceProvider).saveProfile(state);
  }
}

/// Einziger Zugriffspunkt auf das Nutzerprofil (siehe PLAN.md Abschnitt 9,
/// Design-Token-Prinzip — dasselbe Muster wie [themeModeProvider]).
final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
