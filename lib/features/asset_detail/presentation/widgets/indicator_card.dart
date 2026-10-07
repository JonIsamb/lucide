import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../catalog/domain/weekly_candle.dart';
import '../../domain/period_stats.dart';
import 'detail_card.dart';

const _notEnoughData = 'Pas assez de données sur cette période.';

/// The three indicators of the subject, each with one sentence a beginner
/// can read: change, volatility, maximum drawdown.
class IndicatorCard extends StatelessWidget {
  const IndicatorCard({
    super.key,
    required this.stats,
    required this.candles,
    required this.currency,
  });

  final PeriodStats stats;

  /// Candles of the period: gives the dates quoted in the sentences.
  final List<WeeklyCandle> candles;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final change = stats.changePercent;
    final volatility = stats.volatilityPercent;
    final drawdown = stats.drawdown;

    return DetailCard(
      child: Column(
        children: [
          _IndicatorRow(
            title: 'Variation',
            value: change == null ? '—' : formatPercent(change),
            valueColor: change == null ? AppColors.ink : trendColor(change),
            explanation: _changeSentence(),
          ),
          const Divider(),
          _IndicatorRow(
            title: 'Volatilité',
            value: volatility == null
                ? '—'
                : formatPercent(volatility, signed: false),
            explanation: _volatilitySentence(stats.volatilityLevel),
          ),
          const Divider(),
          _IndicatorRow(
            title: 'Baisse maximale',
            value: drawdown == null ? '—' : formatPercent(-drawdown.percent),
            valueColor: drawdown == null || drawdown.percent == 0
                ? AppColors.ink
                : AppColors.fall,
            explanation: _drawdownSentence(drawdown),
          ),
        ],
      ),
    );
  }

  String _changeSentence() {
    final value = stats.valueOf100;
    if (value == null) return _notEnoughData;
    final symbol = currencySymbol(currency);
    return '100 $symbol placés en ${formatMonthYear(candles.first.date)} '
        'vaudraient ${formatPrice(value, currency)}, avant frais et impôts.';
  }

  String _volatilitySentence(VolatilityLevel? level) => switch (level) {
    null => _notEnoughData,
    VolatilityLevel.calm =>
      'Le cours bouge peu d’une semaine à l’autre : c’est calme.',
    VolatilityLevel.moderate =>
      'Le cours bouge, mais sans à-coups extrêmes : c’est modéré.',
    VolatilityLevel.high =>
      'Le cours peut varier fortement en quelques semaines : c’est agité.',
    VolatilityLevel.veryHigh =>
      'Le cours fait de très grands écarts, à la hausse comme à la baisse : '
          'c’est très agité.',
  };

  String _drawdownSentence(Drawdown? drawdown) {
    if (drawdown == null) return _notEnoughData;
    if (drawdown.percent == 0) {
      return 'Le cours n’a jamais reculé sous un sommet sur cette période.';
    }
    final peak = formatDay(candles[drawdown.peakIndex].date);
    final trough = formatDay(candles[drawdown.troughIndex].date);
    return 'Acheté au plus haut ($peak), tu aurais perdu jusqu’à '
        '${formatPercent(drawdown.percent, signed: false)} au plus bas '
        '($trough).';
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({
    required this.title,
    required this.value,
    required this.explanation,
    this.valueColor = AppColors.ink,
  });

  final String title;
  final String value;
  final String explanation;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
