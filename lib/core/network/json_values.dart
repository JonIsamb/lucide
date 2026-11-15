// Defensive conversions of JSON values, shared by every API client.
//
// APIs send numbers as numbers or as strings ("227.40"), and any field may
// be missing or invalid: each function returns null for an unusable value,
// so the caller skips it instead of crashing.

/// A finite number, from a number or a string. Null otherwise (missing,
/// unreadable, NaN or infinite).
double? parseDouble(Object? value) {
  final number = switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value.trim()),
    _ => null,
  };
  return number != null && number.isFinite ? number : null;
}

/// An integer, from a number or a string. Null otherwise.
int? parseInt(Object? value) => switch (value) {
  int() => value,
  num() when value.isFinite => value.toInt(),
  String() => int.tryParse(value.trim()),
  _ => null,
};

/// "2026-10-05" or "2026-10-05 00:00:00" → that day at midnight UTC.
/// UTC avoids a day moving to the previous one with time zones.
DateTime? parseDate(Object? value) {
  if (value is! String || value.length < 10) return null;
  final parsed = DateTime.tryParse(value.substring(0, 10));
  if (parsed == null) return null;
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}
