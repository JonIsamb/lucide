# Décisions

Une entrée par choix : décision, alternative écartée, justification. Ce fichier sert de base au rapport.

## Fiche actif

### Indicateurs calculés sur le cache hebdomadaire

- **Décision** : la fiche n'utilise que les bougies hebdomadaires déjà stockées (`weekly_candles`, environ 5 ans). Variation, volatilité, baisse maximale, plus haut, plus bas, meilleure et pire semaine, part de semaines en hausse et volume moyen en sont tous dérivés (`period_stats.dart`).
- **Alternatives écartées** : un appel `/quote` par fiche (variation du jour, fourchette 52 semaines), ou une série quotidienne dans une nouvelle table.
- **Justification** : aucun crédit Twelve Data en plus, aucune migration drift, et la fiche fonctionne entièrement hors connexion. Le prix à payer (volatilité hebdomadaire, « 1 mois » en 5 points) est noté dans `limitations.md`.

### Graphique de la fiche dessiné avec un `CustomPainter`

- **Décision** : `PriceChart` trace la courbe, l'aire, le repère de baisse maximale (sommet, creux, pointillés, étiquette) et le curseur au doigt dans un `CustomPainter`, animé par un `AnimationController` (tracé en 700 ms, repère en fondu sur les derniers 30 %).
- **Alternative écartée** : `fl_chart`, prévu dans la pile technique.
- **Justification** : le repère de baisse maximale de la maquette demande un dessin libre ; même technique que `Sparkline` et `MysteryChart`, sans dépendance, et le code s'explique ligne par ligne.

### Un contrôleur par symbole, libéré à la fermeture

- **Décision** : `assetDetailControllerProvider` est un `AsyncNotifierProvider.autoDispose.family` indexé par symbole. Il porte la période choisie, l'actualisation en cours et l'erreur éventuelle.
- **Alternative écartée** : garder la période dans un `StatefulWidget`, ou un provider gardé en vie.
- **Justification** : la période est un état de l'application, pas un état visuel. `autoDispose` fait relire le cache à chaque ouverture, donc la décision de rafraîchir est reprise à chaque fois. La relance automatique de Riverpod est désactivée : c'est le bouton « Réessayer » qui décide.

### La décision de rafraîchir reste dans le dépôt

- **Décision** : le contrôleur appelle `CatalogRepository.refreshSeriesIfNeeded(symbol)`, qui applique `needsRefresh` (6 heures) puis la requête incrémentale existante.
- **Alternative écartée** : comparer les dates dans le contrôleur.
- **Justification** : la décision cache ou API n'existe qu'à un endroit ; le contrôleur ignore l'origine des données.

### Favori : une seule source

- **Décision** : l'étoile de la fiche lit et modifie l'état du catalogue (`catalogControllerProvider`).
- **Alternative écartée** : un booléen copié dans l'état de la fiche.
- **Justification** : les deux écrans ne peuvent pas se contredire, et l'animation `FavoriteButton` est réutilisée telle quelle.

### « 100 placés » dans la devise de l'actif

- **Décision** : la phrase de variation dit « 100 $ placés… » pour un actif coté en dollars.
- **Alternative écartée** : « 100 € », comme sur la maquette.
- **Justification** : aucun taux de change n'est appliqué sur la fiche ; annoncer des euros serait faux. L'effet du change est le rôle du simulateur.

### Bouton « Ce que j'aurais vraiment gagné »

- **Décision** : le bouton ouvre l'écran provisoire du simulateur.
- **Alternative écartée** : masquer le bouton tant que le module n'existe pas.
- **Justification** : le parcours de la maquette est visible en démonstration, et un module non terminé ne casse rien.
