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

- **Décision** : `game_verdict.dart` contient les fonctions pures : variation sur les semaines masquées, bonne réponse, comparaison du score au hasard (bornes calculées par `chanceBounds`, voir « Partie de 10 manches »).
- **Alternative écartée** : calculer ces valeurs dans les Widgets.
- **Justification** : Dart pur, testé avec les cas limites (série vide, prix nul, égalité, bornes 1, 2, 8, 9 sur 10 manches et 5, 6, 14, 15 sur 20).

### Barre d'onglets toujours visible

- **Décision** : le jeu reste dans l'onglet Jeu ; « Manche suivante » et « Accueil / Rejouer » sont dans une barre épinglée au-dessus des onglets.
- **Alternative écartée** : masquer les onglets pendant la révélation et le bilan, comme sur la maquette.
- **Justification** : la coque n'a pas à connaître l'état du jeu ; `GameScreen` reçoit seulement un rappel `onGoHome`.

### Statistiques d'exemple derrière un provider

- **Décision** : `gameStatsProvider` (`sample_stats.dart`) fournit des statistiques d'exemple (parties jouées, meilleur score, moyenne).
- **Alternative écartée** : masquer les tuiles tant que les parties ne sont pas enregistrées.
- **Justification** : l'écran de bilan se valide tout de suite ; l'étape de persistance remplacera ce provider, sans toucher aux Widgets.

## Jeu « Teste ton intuition » : vraies courbes, 10 manches, contexte

### Manches tirées dans les cours hebdomadaires en base

- **Décision** : `drawRounds` (`domain/round_draw.dart`) liste toutes les fenêtres de 30 semaines consécutives de tous les actifs en base, puis en tire 10 avec un `Random` reçu en paramètre. `GameRepository` lit les séries via `CatalogRepository.loadAllDetails()` et n'appelle jamais l'API.
- **Alternative écartée** : les courbes inventées de l'étape graphique ; ou un tirage « un actif puis une fenêtre », qui favoriserait les actifs à l'historique court.
- **Justification** : le joueur parie sur de vrais cours, hors connexion ; le tirage est du Dart pur, rejouable en test avec une graine fixe. Chaque semaine en base a la même chance d'être tirée.

### Deux manches ne partagent jamais une semaine du même actif

- **Décision** : après chaque tirage, les fenêtres du même actif qui chevauchent la fenêtre tirée sont retirées des candidates.
- **Alternative écartée** : un tirage sans cette règle.
- **Justification** : deux fenêtres décalées d'une semaine montreraient presque la même courbe, et la révélation de la première donnerait la réponse de la seconde.

### La semaine en cours est exclue

- **Décision** : `GameRepository` retire la bougie la plus récente de chaque série avant le tirage.
- **Alternative écartée** : utiliser toutes les bougies.
- **Justification** : la clôture de la semaine en cours change chaque jour ; la « bonne réponse » d'une manche pourrait changer entre deux parties.

### Partie de 10 manches, bornes du hasard calculées

- **Décision** : `roundsPerGame = 10`. Les bornes du hasard ne sont plus deux constantes : `chanceBounds(n)` applique le test binomial bilatéral au seuil de 5 % et donne 2 à 8 pour 10 manches (6 à 14 pour 20).
- **Alternative écartée** : 20 manches (consigne initiale) ; ou des bornes 2 et 8 écrites en dur.
- **Justification** : une partie plus courte se termine en démonstration. Le calcul est testé pour 10 et pour 20 manches, et reste juste si le nombre de manches change encore. Contrepartie notée dans `limitations.md` : sur 10 manches, seuls 0, 1, 9 et 10 sortent de la zone du hasard.

### Pas de partie raccourcie

- **Décision** : si les cours en base ne permettent pas 10 manches, `drawRounds` renvoie une liste vide et l'écran affiche « jeu indisponible » avec l'explication et un bouton « Réessayer ».
- **Alternative écartée** : jouer avec les manches disponibles.
- **Justification** : le bilan compare le score à une pièce lancée 10 fois ; un autre nombre de manches changerait le sens du message.

### `GameController` devient un `AsyncNotifier`

- **Décision** : `build()` attend le tirage du dépôt ; l'écran lit un `AsyncValue<GameState>` (chargement, jeu indisponible, manche, bilan). « Rejouer » invalide le provider : nouveau tirage.
- **Alternative écartée** : garder un `Notifier` synchrone alimenté par un second provider de manches.
- **Justification** : la lecture de la base est asynchrone ; même schéma que `CatalogController` et `AssetDetailController`.

### Onglet Jeu construit à sa première ouverture

- **Décision** : `HomeShell` ne construit `GameScreen` qu'une fois l'onglet ouvert, puis le garde vivant dans l'`IndexedStack`.
- **Alternative écartée** : le construire au démarrage comme les autres onglets.
- **Justification** : le tirage a lieu à la construction ; au premier lancement, la base est encore vide à ce moment-là et le jeu se déclarerait indisponible alors que le catalogue télécharge les cours.

### Contexte de l'actif à la révélation

- **Décision** : après la réponse, `AssetContextCard` affiche le type, le symbole, le nom et la description de l'actif (texte de `catalog.json`), la variation sur les 26 semaines affichées, celle des 4 semaines suivantes, et un lien vers la fiche.
- **Alternative écartée** : expliquer la période par l'actualité (« krach de mars 2020 »…).
- **Justification** : aucune source d'actualité n'est dans l'app ; un commentaire rédigé à la main serait inventé. Le contexte repose uniquement sur des données déjà en base, donc disponible hors connexion.

## Jeu « Teste ton intuition » : mode indice

### Indice : les annonces de résultats de la période affichée

- **Décision** : « Voir un indice » affiche les annonces de résultats trimestriels publiées pendant les 26 semaines visibles : « Il y a 3 semaines : résultats meilleurs que prévu (+6,3 %) ». Ni nom d'actif, ni date. Les annonces des 4 semaines masquées ne sont jamais montrées.
- **Alternative écartée** : les communiqués de presse (`/press_releases` de Twelve Data) ; ou un indice sans annonces (type d'actif, année).
- **Justification** : `/press_releases` ne renvoie rien sur les périodes passées (testé : vide pour AAPL en 2022, vide pour les ETF et les cryptos) et son contenu récent est surtout promotionnel. Une annonce de résultats est un fait daté et chiffré, et elle sert la promesse du jeu : même en sachant que les résultats étaient bons, la suite reste imprévisible.

### Annonces embarquées dans `assets/earnings.json`

- **Décision** : les annonces sont un fichier versionné, au format de la réponse `/earnings` de Twelve Data (`symbol`, `date`, `eps_estimate`, `eps_actual`, `surprise_prc`), lu par `GameRepository`.
- **Alternative écartée** : appeler `/earnings` depuis l'app et mettre en cache dans drift.
- **Justification** : `/earnings` coûte 20 crédits par symbole et exige le plan Grow ; la clé gratuite (8 crédits par minute) ne peut pas l'appeler. Un fichier embarqué fonctionne hors connexion et ne consomme aucun quota. Aucune dépendance ajoutée.

### Calcul de l'indice dans `domain/`

- **Décision** : `earningsHints` (`domain/earnings_hint.dart`) place chaque annonce dans la semaine qui la contient et renvoie « il y a N semaines » ; `drawRounds` l'appelle en découpant la manche. `EarningsDto.fromJson` (`data/earnings_dto.dart`) convertit le JSON de façon défensive.
- **Alternative écartée** : calculer l'indice dans le Widget à partir des dates.
- **Justification** : Dart pur, testé (bornes de semaine, semaines masquées exclues, nombre en chaîne, ligne invalide ignorée). Un fichier illisible retire seulement les indices : le jeu reste jouable.

### Indice demandé : état dans le `Notifier`, sans pénalité

- **Décision** : `GameState.hintRounds` garde les manches où l'indice a été demandé ; `GameController.showHint()` n'agit qu'avant la réponse. Le score n'est pas modifié.
- **Alternative écartée** : un booléen dans le Widget ; ou une pénalité de score.
- **Justification** : l'état métier reste hors des Widgets et se teste sans interface. Aucune règle de pénalité n'est définie dans la consigne : en inventer une fausserait la comparaison avec la pièce.
