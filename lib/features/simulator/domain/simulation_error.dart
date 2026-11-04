/// Why a simulation cannot be computed. The message is shown as is under
/// the form, so it explains what to change.
enum SimulationError {
  noAsset('Choisis un actif.'),
  amountNotPositive('Le montant investi doit être supérieur à 0 €.'),
  datesInverted('La date d’achat doit être avant la date de vente.'),
  buyBeforeHistory(
    'Cet actif n’a pas de cours à la date d’achat choisie : '
    'choisis une date plus récente.',
  ),
  sellAfterHistory(
    'Cet actif n’a pas de cours à la date de vente choisie : '
    'choisis une date plus ancienne.',
  ),
  noPrices(
    'Aucun cours n’est enregistré pour cet actif. '
    'Ouvre le catalogue avec une connexion pour les télécharger.',
  ),
  peaNotEligible(
    'Cet actif ne peut pas être détenu dans un PEA : '
    'ce plan n’accepte que des titres européens (les actions et ETF '
    'américains et les cryptos en sont exclus). Choisis le compte titres.',
  ),
  brokerageOutOfRange(
    'Les frais de courtage sont trop élevés : ils doivent rester sous '
    '5 % du montant (ou sous le montant lui-même).',
  ),
  annualFeeOutOfRange(
    'Les frais annuels doivent être compris entre 0 % et 5 % par an.',
  ),
  fxMissing(
    'Le taux de change euro-dollar manque pour une des deux dates. '
    'Réessaie avec une connexion.',
  ),
  inflationMissing(
    'Aucune donnée d’inflation n’est disponible. '
    'Réessaie avec une connexion.',
  );

  const SimulationError(this.message);
  final String message;
}
