import 'package:shared_preferences/shared_preferences.dart';

import '../domain/profile.dart';

/// Where the profile is kept between two launches. A few settings do not
/// need the database: they are small key-value pairs.
abstract interface class ProfileStore {
  Future<Profile> load();
  Future<void> save(Profile profile);
}

/// Stores the profile in the platform preferences (UserDefaults on iOS,
/// SharedPreferences on Android). Everything stays on the phone.
class PrefsProfileStore implements ProfileStore {
  static const _firstNameKey = 'profile.first_name';

  @override
  Future<Profile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Profile(firstName: prefs.getString(_firstNameKey) ?? '');
  }

  @override
  Future<void> save(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, profile.firstName);
  }
}
