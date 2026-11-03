import '../../catalog/domain/instrument.dart';

/// Where the shares are held. It decides the tax rate.
enum Envelope {
  securitiesAccount('Compte titres'),
  pea('PEA');

  const Envelope(this.label);
  final String label;
}

/// How the broker's fee is entered. The same fee is paid on the purchase
/// and on the sale.
enum BrokerageKind { amount, percent }

/// Highest broker fee accepted, as a percentage of the amount.
const maxBrokeragePercent = 5.0;

/// Highest yearly fee accepted (fund or custody fees), in % per year.
const maxAnnualFeePercent = 5.0;

/// Everything the user chose in the form, frozen with the asset facts that
/// the rules need (type, currency, PEA eligibility). A saved simulation
/// stores it as is, so it never depends on the catalogue again.
class SimulationParams {
  const SimulationParams({
    required this.symbol,
    required this.assetName,
    required this.assetType,
    required this.currency,
    required this.peaEligible,
    required this.amount,
    required this.buyDay,
    required this.sellDay,
    required this.envelope,
    this.brokerageKind = BrokerageKind.percent,
    this.brokerageValue = 0,
    this.annualFeePercent = 0,
  });

  final String symbol;
  final String assetName;
  final InstrumentType assetType;

  /// Quote currency of the asset: "USD" or "EUR".
  final String currency;
  final bool peaEligible;

  /// Money invested, in euros.
  final double amount;

  /// Plain days in UTC.
  final DateTime buyDay;
  final DateTime sellDay;
  final Envelope envelope;
  final BrokerageKind brokerageKind;

  /// Euros or percent, depending on [brokerageKind].
  final double brokerageValue;
  final double annualFeePercent;

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'assetName': assetName,
    'assetType': assetType.name,
    'currency': currency,
    'peaEligible': peaEligible,
    'amount': amount,
    'buyDay': _day(buyDay),
    'sellDay': _day(sellDay),
    'envelope': envelope.name,
    'brokerageKind': brokerageKind.name,
    'brokerageValue': brokerageValue,
    'annualFeePercent': annualFeePercent,
  };

  factory SimulationParams.fromJson(Map<String, dynamic> json) {
    return SimulationParams(
      symbol: json['symbol'] as String,
      assetName: json['assetName'] as String,
      assetType: InstrumentType.fromName(json['assetType'] as String?),
      currency: json['currency'] as String,
      peaEligible: json['peaEligible'] as bool,
      amount: (json['amount'] as num).toDouble(),
      buyDay: DateTime.parse('${json['buyDay']}T00:00:00Z'),
      sellDay: DateTime.parse('${json['sellDay']}T00:00:00Z'),
      envelope: Envelope.values.byName(json['envelope'] as String),
      brokerageKind: BrokerageKind.values.byName(
        json['brokerageKind'] as String,
      ),
      brokerageValue: (json['brokerageValue'] as num).toDouble(),
      annualFeePercent: (json['annualFeePercent'] as num).toDouble(),
    );
  }
}

String _day(DateTime d) => d.toIso8601String().substring(0, 10);
