import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_store.dart';
import '../domain/profile.dart';

final profileStoreProvider = Provider<ProfileStore>(
  (ref) => PrefsProfileStore(),
);

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile>(
      ProfileController.new,
      // Reading the preferences either works or the profile stays empty.
      retry: (_, _) => null,
    );

/// Holds the profile and writes it to the phone at each change.
class ProfileController extends AsyncNotifier<Profile> {
  ProfileStore get _store => ref.read(profileStoreProvider);

  /// A profile that cannot be read is an empty one: the rest of the app
  /// must not depend on it.
  @override
  Future<Profile> build() async {
    try {
      return await _store.load();
    } on Object {
      return Profile.empty;
    }
  }

  /// Saves the first name as cleaned by [Profile.cleanName]. The screen
  /// shows the new name at once, even if writing fails (the name is then
  /// lost at the next launch).
  Future<void> setFirstName(String raw) async {
    final profile = Profile(firstName: Profile.cleanName(raw));
    state = AsyncData(profile);
    try {
      await _store.save(profile);
    } on Object {
      return;
    }
  }
}
