// The words of the "Expliquer la réponse" card. Plain functions of the
// numbers computed in the domain, so they can be tested without a widget.

import '../../../core/utils/formatters.dart';
import '../domain/earnings_announcement.dart';
import '../domain/window_regime.dart';

/// "Une période calme", "Une période agitée", "Une période de crise".
String regimeTitle(MarketRegime regime) => switch (regime) {
  MarketRegime.calm => 'Une période calme',
  MarketRegime.lively => 'Une période agitée',
  MarketRegime.crisis => 'Une période de crise',
};

/// What the numbers say, in a sentence. Nothing about the causes.
String regimeSentence(WindowAnalysis analysis) {
  final trend = switch (analysis.trend) {
    WindowTrend.up =>
      'Le cours a progressé de '
          '${formatPercent(analysis.changePercent, signed: false)}',
    WindowTrend.down =>
      'Le cours a reculé de '
          '${formatPercent(analysis.changePercent.abs(), signed: false)}',
    WindowTrend.flat =>
      'Le cours est resté à peu près stable '
          '(${formatPercent(analysis.changePercent)})',
  };
  final fall = analysis.drawdownPercent < 0.05
      ? 'il n\'a jamais reculé depuis un sommet'
      : 'sa plus forte baisse depuis un sommet a été de '
            '${formatPercent(analysis.drawdownPercent, signed: false)}';
  return '$trend sur ces ${analysis.weeks} semaines, $fall, avec des '
      'variations hebdomadaires qui, ramenées sur un an, représentent '
      '${formatPercent(analysis.volatilityPercent, signed: false)}.';
}

/// What this kind of period means for a beginner.
String regimeMeaning(MarketRegime regime) => switch (regime) {
  MarketRegime.calm =>
    'Quand la bourse est calme, rien ne se passe de spectaculaire, et '
        'c\'est normal : l\'essentiel du temps, les prix évoluent sans '
        'nouvelle marquante. Le calme ne garantit pas la suite : '
        'une période tranquille peut précéder une période agitée.',
  MarketRegime.lively =>
    'Les prix bougent beaucoup, sans que ce soit une crise. Un marché '
        'agité alterne hausses et baisses rapides : c\'est le prix à payer '
        'pour espérer gagner plus qu\'avec un placement sans risque.',
  MarketRegime.crisis =>
    'Une baisse de cette ampleur est une crise, ou un « marché '
        'baissier ». Elle fait mal à voir, mais elle fait partie de la vie '
        'de la bourse : elle arrive de temps en temps, sans prévenir.',
};

/// "Comment réagir" tips for a regime. General principles, not advice
/// about one asset.
List<String> regimeTips(MarketRegime regime) => switch (regime) {
  MarketRegime.crisis => const [
    'Ne vends pas dans la panique : une baisse n\'est une perte réelle que '
        'si tu vends. Les prix peuvent remonter, mais on ne sait ni quand '
        'ni si un actif précis remontera.',
    'Ne mets en bourse que de l\'argent dont tu n\'as pas besoin à court '
        'terme. Si tu dois vendre au pire moment, la crise te coûte '
        'vraiment.',
    'Répartis ton argent : plusieurs actifs et plusieurs secteurs limitent '
        'les dégâts quand un seul s\'effondre.',
    'Investir un petit montant régulièrement, plutôt qu\'en une fois, '
        'évite d\'acheter tout au plus haut.',
    'Évite les achats à crédit ou avec effet de levier : en crise, ils '
        'peuvent te forcer à vendre.',
  ],
  MarketRegime.lively => const [
    'Regarde ton horizon : sur plusieurs années, une semaine agitée '
        'compte peu.',
    'Fixe-toi un plan avant d\'investir et suis-le, au lieu de réagir à '
        'chaque titre de journal.',
    'Répartir son argent sur plusieurs actifs adoucit les secousses.',
  ],
  MarketRegime.calm => const [
    'Le calme est le bon moment pour construire un plan : combien '
        'investir, sur combien de temps, quelle perte tu supportes.',
    'Ne prends pas le calme pour une garantie : prépare-toi à des '
        'périodes plus agitées.',
  ],
};

/// One announcement of the round, with its day.
/// "30 oct. 2025 : résultats meilleurs que prévu (+4,5 %)."
String earningsSentence(EarningsAnnouncement announcement) {
  final percent = announcement.surprisePercent;
  final String what;
  if (percent == null) {
    what = 'résultats publiés';
  } else if (percent > 0) {
    what = 'résultats meilleurs que prévu (${formatPercent(percent)})';
  } else if (percent < 0) {
    what = 'résultats moins bons que prévu (${formatPercent(percent)})';
  } else {
    what = 'résultats conformes aux attentes';
  }
  return '${formatDay(announcement.day)} : $what.';
}

/// Said when no event of the list covers the round.
const noEventSentence =
    'Aucun événement de notre liste ne couvre cette période. Un prix peut '
    'bouger sans nouvelle marquante : l\'achat et la vente de millions '
    'd\'investisseurs suffisent.';

const explanationDisclaimer =
    'Les événements sont mis en regard des prix, mais coïncider n\'est pas '
    'prouver : personne ne peut dire précisément ce qui a causé un '
    'mouvement. Contenu pédagogique, pas un conseil en investissement.';

/// Said before the answer when no event of the list was going on.
const noContextEventSentence =
    'Aucun événement majeur de notre liste ne se passait pendant ces '
    'semaines. Les prix bougent aussi sans nouvelle marquante.';

const contextDisclaimer =
    'Ce contexte est ce qui était connu à la fin des semaines affichées. '
    'Il aide à réfléchir, mais ne garantit rien : personne ne sait ce que '
    'fera un cours dans les semaines suivantes.';
