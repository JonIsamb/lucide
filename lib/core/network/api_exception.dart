/// The kinds of failure the app knows how to explain to the user.
enum ApiErrorKind {
  /// No connection, DNS failure, timeout.
  network,

  /// Twelve Data quota reached (8 per minute or 800 per day).
  rateLimit,

  /// Missing or wrong API key.
  invalidKey,

  /// Unknown symbol, or not available on the free plan.
  notFound,

  /// Anything else (server error, unreadable answer...).
  unknown,
}

/// Every network error is converted to this single type, so the rest of
/// the app never deals with HTTP codes or JSON details.
class ApiException implements Exception {
  const ApiException(this.kind, [this.details = '']);

  final ApiErrorKind kind;

  /// Technical details for logs and debugging, not shown to the user.
  final String details;

  /// Message in French, ready to display.
  String get userMessage => switch (kind) {
    ApiErrorKind.network => 'Pas de connexion. Vérifie ton réseau et réessaie.',
    ApiErrorKind.rateLimit =>
      'Trop de demandes envoyées. Réessaie dans une minute.',
    ApiErrorKind.invalidKey =>
      'La clé d’accès aux cours est absente ou invalide.',
    ApiErrorKind.notFound => 'Cet actif est introuvable.',
    ApiErrorKind.unknown =>
      'Le service des cours ne répond pas correctement. Réessaie plus tard.',
  };

  @override
  String toString() => 'ApiException($kind, $details)';
}
