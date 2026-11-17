// The user's profile. Pure Dart: no storage, no widget.

/// Longest first name accepted, so it fits the greeting and the avatar.
const maxFirstNameLength = 24;

class Profile {
  const Profile({this.firstName = ''});

  /// Empty until the user fills it.
  final String firstName;

  static const empty = Profile();

  bool get hasName => firstName.isNotEmpty;

  /// First letter of each word, at most two, in capitals: "Jean Paul" is
  /// "JP". Empty without a name.
  String get initials {
    final words = firstName.split(RegExp(r'[\s-]+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w.substring(0, 1).toUpperCase()).join();
  }

  /// The name as typed in a form: spaces trimmed and squeezed, cut to
  /// [maxFirstNameLength].
  static String cleanName(String raw) {
    final squeezed = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    return squeezed.length <= maxFirstNameLength
        ? squeezed
        : squeezed.substring(0, maxFirstNameLength).trimRight();
  }
}
