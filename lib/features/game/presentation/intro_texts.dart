// Sentences of the game's welcome screen. Pure functions, tested without
// any widget.

import '../domain/game_verdict.dart';
import '../domain/round_draw.dart';

/// "Au hasard, une pièce fait entre 2 et 8 sur 10. Pour dépasser le
/// hasard, il faut 9 ou plus."
String targetScoreSentence(int rounds) {
  final bounds = chanceBounds(rounds);
  return 'Au hasard (pile ou face), on obtient entre ${bounds.lower} et '
      '${bounds.upper} bonnes réponses sur $rounds. Pour que ton score ne '
      's’explique plus par la chance, il faut ${bounds.upper + 1} ou plus.';
}

/// How a past score compares with chance, in a few words.
String verdictLabel(ChanceVerdict verdict) => switch (verdict) {
  ChanceVerdict.withinChance => 'Comme le hasard',
  ChanceVerdict.aboveChance => 'Au dessus du hasard',
  ChanceVerdict.belowChance => 'Sous le hasard',
};

/// What the game is, in one sentence.
String howItWorks(int rounds) =>
    '$rounds manches. À chaque manche, tu vois $visibleWeeks semaines de '
    'cours ramenées à 100 au départ : le cours sera-t-il plus haut ou plus '
    'bas $hiddenWeeks semaines plus tard ?';

/// Advice before playing. Each one is true of the game as built.
final gameHints = <(String icon, String text)>[
  (
    'context',
    'Avant de parier, déplie la carte « contexte » : l’entreprise, la '
        'période, l’état du marché et les résultats publiés. Jamais ce qui '
        'se passe pendant les semaines cachées.',
  ),
  (
    'trend',
    'Une courbe qui monte depuis 6 mois n’annonce presque jamais la suite. '
        'Ne te fie pas à la tendance seule.',
  ),
  (
    'flat',
    'Un cours inchangé compte comme « plus bas » : il n’a pas fini plus '
        'haut.',
  ),
  (
    'explain',
    'Après chaque réponse, la suite se révèle. Le bouton d’explication '
        'donne les raisons possibles du mouvement. Aucune pénalité.',
  ),
  (
    'chance',
    'Un score au niveau du hasard n’est pas un échec : personne ne prédit '
        'une courbe à court terme, pas même les professionnels.',
  ),
  (
    'time',
    'Prends ton temps : pas de chrono. Le jeu marche aussi hors connexion, '
        'avec les cours enregistrés sur le téléphone.',
  ),
];
