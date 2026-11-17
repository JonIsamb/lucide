import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/profile/data/profile_store.dart';
import 'package:lucide/features/profile/domain/profile.dart';
import 'package:lucide/features/profile/presentation/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryStore implements ProfileStore {
  Profile saved = Profile.empty;
  bool failing = false;

  @override
  Future<Profile> load() async {
    if (failing) throw StateError('unreadable');
    return saved;
  }

  @override
  Future<void> save(Profile profile) async {
    if (failing) throw StateError('unwritable');
    saved = profile;
  }
}

void main() {
  group('Profile', () {
    test('initials: one or two letters, capitals', () {
      expect(const Profile(firstName: 'jonathan').initials, 'J');
      expect(const Profile(firstName: 'jean paul').initials, 'JP');
      expect(const Profile(firstName: 'Anne-Sophie').initials, 'AS');
      expect(const Profile(firstName: 'a b c').initials, 'AB');
    });

    test('no name: no initials', () {
      expect(Profile.empty.hasName, isFalse);
      expect(Profile.empty.initials, isEmpty);
    });

    test('cleanName trims, squeezes spaces and cuts the length', () {
      expect(Profile.cleanName('  Jean   Paul '), 'Jean Paul');
      expect(Profile.cleanName('   '), '');
      expect(Profile.cleanName('x' * 40), hasLength(maxFirstNameLength));
    });
  });

  group('ProfileController', () {
    late _MemoryStore store;
    late ProviderContainer container;

    setUp(() {
      store = _MemoryStore();
      container = ProviderContainer(
        overrides: [profileStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
    });

    test('starts from the stored profile', () async {
      store.saved = const Profile(firstName: 'Léa');
      final profile = await container.read(profileControllerProvider.future);
      expect(profile.firstName, 'Léa');
    });

    test('saving cleans the name, shows it and stores it', () async {
      await container.read(profileControllerProvider.future);
      await container
          .read(profileControllerProvider.notifier)
          .setFirstName('  Léa  ');
      expect(container.read(profileControllerProvider).value!.firstName, 'Léa');
      expect(store.saved.firstName, 'Léa');
    });

    test('an unreadable store gives an empty profile, not an error', () async {
      store.failing = true;
      final profile = await container.read(profileControllerProvider.future);
      expect(profile.hasName, isFalse);
    });

    test('a failing write keeps the new name on screen', () async {
      await container.read(profileControllerProvider.future);
      store.failing = true;
      await container
          .read(profileControllerProvider.notifier)
          .setFirstName('Léa');
      expect(container.read(profileControllerProvider).value!.firstName, 'Léa');
    });
  });

  group('PrefsProfileStore', () {
    test('a saved name is read again at the next launch', () async {
      SharedPreferences.setMockInitialValues({});
      await PrefsProfileStore().save(const Profile(firstName: 'Léa'));
      expect((await PrefsProfileStore().load()).firstName, 'Léa');
    });

    test('nothing stored gives the empty profile', () async {
      SharedPreferences.setMockInitialValues({});
      expect((await PrefsProfileStore().load()).hasName, isFalse);
    });
  });
}
