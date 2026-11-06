import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/features/game/domain/earnings_announcement.dart';
import 'package:lucide/features/game/domain/window_regime.dart';
import 'package:lucide/features/game/presentation/explanation_texts.dart';

String plain(String text) => text.replaceAll(' ', ' ').replaceAll(' ', ' ');

WindowAnalysis analysis({
  WindowTrend trend = WindowTrend.up,
  double change = 12.3,
  double drawdown = 4.0,
  double volatility = 18.0,
}) => WindowAnalysis(
  regime: MarketRegime.calm,
  trend: trend,
  weeks: 30,
  changePercent: change,
  volatilityPercent: volatility,
  drawdownPercent: drawdown,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('regimeSentence', () {
    test('a rise, a fall from a peak and the volatility', () {
      expect(
        plain(regimeSentence(analysis())),
        'Le cours a progressé de 12,3 % sur ces 30 semaines, sa plus forte '
        'baisse depuis un sommet a été de 4,0 %, avec des variations '
        'hebdomadaires qui, ramenées sur un an, représentent 18,0 %.',
      );
    });

    test('a fall is written without a minus sign', () {
      final text = plain(
        regimeSentence(analysis(trend: WindowTrend.down, change: -25.0)),
      );
      expect(text, startsWith('Le cours a reculé de 25,0 %'));
    });

    test('a flat price keeps its small signed change', () {
      final text = plain(
        regimeSentence(analysis(trend: WindowTrend.flat, change: 1.2)),
      );
      expect(text, startsWith('Le cours est resté à peu près stable (+1,2 %)'));
    });

    test('a price that never fell from a peak says so', () {
      expect(
        regimeSentence(analysis(drawdown: 0)),
        contains('il n\'a jamais reculé depuis un sommet'),
      );
    });
  });

  group('regime texts', () {
    test('every regime has a title, a meaning and tips', () {
      for (final regime in MarketRegime.values) {
        expect(regimeTitle(regime), isNotEmpty);
        expect(regimeMeaning(regime), isNotEmpty);
        expect(regimeTips(regime), isNotEmpty);
      }
    });

    test('the crisis tips tell not to sell in panic', () {
      expect(
        regimeTips(MarketRegime.crisis).first,
        startsWith('Ne vends pas dans la panique'),
      );
    });

    test('calm periods are not described as safe', () {
      expect(regimeMeaning(MarketRegime.calm), contains('ne garantit pas'));
    });
  });

  group('earningsSentence', () {
    final day = DateTime.utc(2025, 10, 30);

    test('better, worse, in line and unknown', () {
      expect(
        plain(
          earningsSentence(
            EarningsAnnouncement(day: day, surprisePercent: 4.5),
          ),
        ),
        '30 oct. 2025 : résultats meilleurs que prévu (+4,5 %).',
      );
      expect(
        plain(
          earningsSentence(
            EarningsAnnouncement(day: day, surprisePercent: -2.0),
          ),
        ),
        '30 oct. 2025 : résultats moins bons que prévu (−2,0 %).',
      );
      expect(
        earningsSentence(EarningsAnnouncement(day: day, surprisePercent: 0)),
        '30 oct. 2025 : résultats conformes aux attentes.',
      );
      expect(
        earningsSentence(EarningsAnnouncement(day: day)),
        '30 oct. 2025 : résultats publiés.',
      );
    });
  });
}
