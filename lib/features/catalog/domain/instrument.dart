/// The kind of asset. The French labels live here so the UI, the filters
/// and the simulator all use the same words.
enum InstrumentType {
  stock('Action', 'Actions'),
  etf('ETF', 'ETF'),
  crypto('Crypto', 'Cryptos');

  const InstrumentType(this.label, this.pluralLabel);

  /// Singular, used in row subtitles: "Action, 227,40 $".
  final String label;

  /// Plural, used on the filter chips.
  final String pluralLabel;

  /// Reads the `type` field of catalog.json. Unknown values fall back to
  /// stock instead of crashing the whole catalogue.
  static InstrumentType fromName(String? name) => switch (name) {
    'etf' => InstrumentType.etf,
    'crypto' => InstrumentType.crypto,
    _ => InstrumentType.stock,
  };
}

/// One asset of the catalogue, as described in assets/catalog.json.
/// It never changes at runtime: prices live in WeeklyCandle.
class Instrument {
  const Instrument({
    required this.symbol,
    required this.name,
    required this.type,
    required this.currency,
    required this.peaEligible,
    required this.description,
    this.exchange,
  });

  /// Twelve Data symbol, e.g. "AAPL" or "BTC/EUR".
  final String symbol;
  final String name;
  final InstrumentType type;

  /// ISO code of the quote currency: "USD" or "EUR".
  final String currency;

  /// Used later by the simulator to refuse a PEA for US assets.
  final bool peaEligible;

  /// One simple French sentence, shown later on the detail screen.
  final String description;

  /// Stock exchange (e.g. "NYSE"). Some tickers such as SPY also exist on
  /// foreign exchanges, so we send it to the API to get the US listing.
  /// Null for cryptos.
  final String? exchange;

  /// Short code for the logo fallback: "BTC" for "BTC/EUR", "AAPL" for "AAPL".
  String get shortCode => symbol.split('/').first;

  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      type: InstrumentType.fromName(json['type'] as String?),
      currency: json['currency'] as String? ?? 'USD',
      peaEligible: json['peaEligible'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      exchange: json['exchange'] as String?,
    );
  }
}
