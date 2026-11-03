import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/core/theme/app_theme.dart';
import 'package:lucide/features/simulator/domain/run_simulation.dart';
import 'package:lucide/features/simulator/domain/simulation_params.dart';
import 'package:lucide/features/simulator/domain/simulation_result.dart';
import 'package:lucide/features/simulator/presentation/cascade_progress.dart';
import 'package:lucide/features/simulator/presentation/widgets/result_view.dart';

import '../../../helpers.dart';

SimulationResult _result() => runSimulation(
  params: SimulationParams(
    symbol: 'KO',
    assetName: 'Coca-Cola',
    assetType: instrument('KO').type,
    currency: 'EUR',
    peaEligible: false,
    amount: 1000,
    buyDay: DateTime.utc(2020, 1, 6),
    sellDay: DateTime.utc(2025, 1, 6),
    envelope: Envelope.securitiesAccount,
  ),
  candles: [
    candle(DateTime.utc(2020, 1, 6), 100),
    candle(DateTime.utc(2025, 1, 6), 120),
  ],
  fxRates: const [],
  inflationPercent: const {
    2020: 1,
    2021: 1,
    2022: 1,
    2023: 1,
    2024: 1,
    2025: 1,
  },
).result!;

String _plain(String s) => s.replaceAll(RegExp(r'[  ]'), ' ');

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('runningPerformance', () {
    test('starts at nothing and ends on the real performance', () {
      final r = _result();
      expect(runningPerformance(r, 0), 0);
      expect(runningPerformance(r, 1), closeTo(r.realPerformance, 1e-12));
    });

    test('reaches the announced gain before the first step starts', () {
      final r = _result();
      expect(runningPerformance(r, 0.21), closeTo(r.grossPerformance, 1e-12));
    });
  });

  Future<void> pump(WidgetTester tester, {bool animate = true}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ResultView(
            result: _result(),
            animate: animate,
            isSaved: false,
            onSave: () {},
            onBack: () {},
          ),
        ),
      ),
    );
  }

  Finder text(String value) =>
      find.byWidgetPredicate((w) => w is Text && _plain(w.data ?? '') == value);

  testWidgets('numbers start at zero and the skip button jumps to the end', (
    tester,
  ) async {
    await pump(tester);
    final real = _result().realPerformance;

    expect(text('0,0 %'), findsWidgets);
    expect(find.text('Passer l’animation'), findsOneWidget);

    await tester.tap(find.text('Passer l’animation'));
    await tester.pump();

    expect(find.text('Passer l’animation'), findsNothing);
    expect(find.text('Rejouer l’animation'), findsOneWidget);
    expect(
      text('+${(real * 100).toStringAsFixed(1).replaceAll('.', ',')} %'),
      findsWidgets,
    );
    expect(text('+20,0 % annoncés'), findsOneWidget);
  });

  testWidgets('the animation ends by itself', (tester) async {
    await pump(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Rejouer l’animation'), findsOneWidget);
  });

  testWidgets('a saved simulation shows its final numbers at once', (
    tester,
  ) async {
    await pump(tester, animate: false);
    expect(find.text('Passer l’animation'), findsNothing);
    expect(text('+20,0 % annoncés'), findsOneWidget);
  });

  testWidgets('replay restarts from zero', (tester) async {
    await pump(tester, animate: false);
    await tester.tap(find.text('Rejouer l’animation'));
    await tester.pump();
    expect(find.text('Passer l’animation'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}
