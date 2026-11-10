// Sentences of the home screen built from the saved data. Pure functions,
// tested without any widget.

import '../../core/utils/formatters.dart';
import '../game/domain/game_verdict.dart';
import '../game/domain/played_game.dart';
import '../simulator/domain/simulation_params.dart';
import '../simulator/domain/simulation_result.dart';

/// "S&P 500, 1 000 € sur 2 ans".
String simulationTitle(SimulationParams params) =>
    '${params.assetName}, '
    '${formatPrice(params.amount, 'EUR', compact: true)} '
    'sur ${formatDuration(params.buyDay, params.sellDay)}';

/// What follows the big real performance: "+3,7 % gagnés en pouvoir
/// d'achat", but "−4,2 % de pouvoir d'achat" (a loss is not "gagnés").
String realGainCaption(double realPerformance) =>
    realPerformance >= 0 ? 'gagnés en\npouvoir d’achat' : 'de pouvoir\nd’achat';

/// Replaces the bar when nothing is left in purchasing power.
String nothingLeftSentence(SimulationResult result) =>
    result.grossPerformance <= 0
    ? 'Le cours n’a pas monté sur la période : il n’y avait aucun gain à '
          'partager.'
    : 'Après change, frais, impôt et inflation, il ne reste rien du gain '
          'annoncé.';

/// ["Change", "Frais"] → "Change, frais".
String costsSentence(Iterable<CascadeStep> steps) {
  final text = steps.map((s) => s.label.toLowerCase()).join(', ');
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Subtitle of the game shortcut while the history is being read, or when
/// it cannot be: the game itself still works.
const gameTagline = 'Devine la suite de vraies courbes.';

/// "Dernière partie : 6/10, comme une pièce", or an invitation to play
/// when no game was finished yet.
String lastGameSubtitle(PlayedGame? game) {
  if (game == null) {
    return 'Pas encore de partie : devine la suite de $roundsPerGame vraies '
        'courbes.';
  }
  final comparison = switch (chanceVerdict(
    game.score,
    rounds: game.roundCount,
  )) {
    ChanceVerdict.withinChance => 'comme une pièce',
    ChanceVerdict.aboveChance => 'mieux qu’une pièce',
    ChanceVerdict.belowChance => 'moins bien qu’une pièce',
  };
  return 'Dernière partie : ${game.score}/${game.roundCount}, $comparison';
}
