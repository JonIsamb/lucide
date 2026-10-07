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

## Jeu « Teste ton intuition » : écrans (étape graphique)

### Courbe du jeu dessinée avec un `CustomPainter`

- **Décision** : `MysteryChart` dessine la courbe, la zone masquée et la suite révélée dans un `CustomPainter`.
- **Alternative écartée** : `fl_chart`.
- **Justification** : la révélation trace la suite point par point (longueur de tracé pilotée par un `AnimationController`), ce qui demande un contrôle direct du dessin. Aucune dépendance ajoutée, et le code reste court et explicable, sur le modèle de `Sparkline`.

### Palette de l'app plutôt que celle des maquettes

- **Décision** : les écrans du jeu reprennent la mise en page des maquettes avec les couleurs d'`AppColors` (bordeaux, sable). Deux teintes ajoutées : `riseTint` et `fallTint`, pour les fonds des bandeaux de résultat.
- **Alternative écartée** : le violet des maquettes, réservé au jeu.
- **Justification** : une seule identité visuelle dans toute l'app ; les couleurs gardent le même sens partout (vert : hausse, corail : baisse).

### Couleur du bandeau : bonne ou mauvaise réponse ; flèche : sens du cours

- **Décision** : le bandeau de révélation est vert quand le joueur a raison et corail quand il a tort ; la flèche et la suite de la courbe indiquent ce que le cours a fait.
- **Alternative écartée** : tout colorer selon le sens du cours.
- **Justification** : le joueur veut d'abord savoir s'il a gagné la manche.

### État du jeu dans un `Notifier`, animation dans le Widget

- **Décision** : `GameController` (`Notifier<GameState>`) porte la manche courante, les réponses et la phase. Le seul état gardé dans un Widget est l'`AnimationController` de la révélation, créé dans `initState` et libéré dans `dispose`.
- **Alternative écartée** : un `StatefulWidget` qui garde les réponses.
- **Justification** : la partie survit au changement d'onglet et se teste sans interface (`game_controller_test.dart`).

### Règles du jeu dans `domain/`

- **Décision** : `game_verdict.dart` contient les fonctions pures : variation sur les semaines masquées, bonne réponse, comparaison du score au hasard (bornes 6 et 14).
- **Alternative écartée** : calculer ces valeurs dans les Widgets.
- **Justification** : Dart pur, testé avec les cas limites (série vide, prix nul, égalité, bornes 5, 6, 14, 15).

### Barre d'onglets toujours visible

- **Décision** : le jeu reste dans l'onglet Jeu ; « Manche suivante » et « Accueil / Rejouer » sont dans une barre épinglée au-dessus des onglets.
- **Alternative écartée** : masquer les onglets pendant la révélation et le bilan, comme sur la maquette.
- **Justification** : la coque n'a pas à connaître l'état du jeu ; `GameScreen` reçoit seulement un rappel `onGoHome`.

### Données d'exemple derrière un provider

- **Décision** : `gameRoundsProvider` et `gameStatsProvider` (`sample_rounds.dart`) fournissent 20 manches et des statistiques d'exemple.
- **Alternative écartée** : attendre le tirage réel pour construire les écrans.
- **Justification** : les écrans se valident tout de suite ; l'étape fonctionnelle remplacera ces deux providers par un dépôt, sans toucher aux Widgets.
