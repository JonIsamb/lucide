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

## Jeu « Teste ton intuition » : mode indice (remplacé)

> **Remplacé** par « Contexte avant la réponse », plus bas : le mode indice, `earningsHints`, `GameState.hintRounds` et `GameController.showHint()` n'existent plus. Les annonces de résultats sont affichées dans la carte de contexte, avec leur date et le nom de l'entreprise.

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

## Simulation « Ce que j'aurais vraiment gagné »

### Cascade en cinq étapes, barres = écarts de performances cumulées

- **Décision** : `runSimulation` (`domain/run_simulation.dart`) calcule cinq performances cumulées en fraction du montant investi : brute (prix de vente / prix d'achat − 1), en euros, après frais, après impôt, réelle (Fisher). Chaque barre est l'écart entre deux performances successives ; la somme des barres plus la performance brute égale le résultat par construction (test dédié).
- **Alternative écartée** : calculer chaque barre isolément (impact du change seul, des frais seuls…).
- **Justification** : des effets calculés séparément ne s'additionnent pas (l'impôt dépend des frais, l'inflation de l'impôt). L'ordre fixe rend la décomposition unique et le graphique honnête.

### Résultat et erreurs sans exception

- **Décision** : `runSimulation` renvoie un `SimulationOutcome` (résultat ou `SimulationError`) ; chaque erreur porte son message français, affiché tel quel sous le formulaire.
- **Alternative écartée** : lever des exceptions de validation.
- **Justification** : un formulaire invalide est un cas normal, pas une exception. Le Notifier n'a pas de `try/catch` et le domaine reste pur.

### Règles fiscales en constantes, une par taux

- **Décision** : `domain/fiscal_rules_2026.dart` contient 31,4 %, 18,6 %, 31,4 % (PEA moins de 5 ans) et le seuil de 305 €. PEA de 5 ans exactement : taux réduit (la date de vente doit être au moins cinq ans après l'achat). Seuil crypto : la cession brute (avant frais) compte, 305 € est exonéré, 306 € est taxé.
- **Alternative écartée** : taux saisis dans l'interface.
- **Justification** : un taux est une règle, pas une donnée utilisateur. Une constante datée se corrige en un endroit et se cite dans le rapport. Les valeurs viennent du cahier des charges, non revérifiées sur le site de l'administration (noté dans le fichier).

### Données de change et d'inflation : seed embarqué, réseau en complément

- **Décision** : `assets/seed/fx_eur_usd.json` (Frankfurter, 2019-12-31 à 2026-11-02) et `assets/seed/inflation_fra.json` (Banque mondiale, `FP.CPI.TOTL.ZG`, 2015 à 2025) sont copiés en base au premier usage si les tables sont vides. Le réseau complète ensuite en arrière-plan ; un échec est ignoré et les données stockées restent utilisées.
- **Alternative écartée** : exiger le réseau au premier calcul.
- **Justification** : la démonstration hors connexion doit fonctionner dès le premier lancement. Les deux sources sont publiques, sans clé ni quota à gérer ; les fichiers ont été téléchargés tels quels, aucun chiffre n'est saisi à la main.

### Tables `fx_rates`, `inflation_rates`, `simulations` (schéma v2)

- **Décision** : trois tables ajoutées avec une migration `onUpgrade` (`from < 2`). `fx_rates` et `inflation_rates` ont chacune un DAO (données réseau) ; `simulations` a le sien (données utilisateur), donc la purge du cache ne touche jamais les simulations sauvegardées. Une simulation stocke ses paramètres et son résultat en JSON.
- **Alternative écartée** : colonnes séparées pour chaque paramètre et chaque résultat ; colonne `is_estimate` dans `inflation`.
- **Justification** : une simulation relue n'est jamais recalculée, donc un instantané JSON suffit et supporte l'ajout de champs. « Estimé » dépend de la période choisie, pas de l'année : c'est calculé à chaque simulation et figé dans son résultat.

### Animation : un seul contrôleur, des tranches de temps

- **Décision** : `ResultView` possède un `AnimationController` (créé dans `initState`, libéré dans `dispose`). `cascade_progress.dart` découpe 0 à 1 en cinq `Interval` : gain annoncé, puis change, frais, impôt, inflation. Le compteur géant, les montants en euros, les lignes d'étapes et le `CustomPainter` en cascade lisent tous le même `t`, donc restent synchronisés.
- **Alternative écartée** : un contrôleur par chiffre ; `TweenAnimationBuilder` par widget.
- **Justification** : la fonction `runningPerformance` est pure et testée (0 au début, résultat réel à la fin) ; la cascade et les chiffres ne peuvent pas se désynchroniser.

### Passer l'animation

- **Décision** : le bouton « Passer l'animation » et un appui sur le graphique placent le contrôleur sur 1 (valeurs finales). Une fois terminée, « Rejouer l'animation » apparaît. L'animation est sautée d'emblée quand le système demande de réduire les animations et pour une simulation sauvegardée relue.
- **Alternative écartée** : réglage global mémorisé « toujours passer ».
- **Justification** : le besoin est de ne pas attendre, pas de configurer. Le bouton est dans la carte qui anime les chiffres, là où le geste est naturel.

### Onglet construit à sa première ouverture

- **Décision** : `HomeShell` ne construit `SimulatorScreen` qu'à l'ouverture de l'onglet, comme pour le jeu.
- **Alternative écartée** : le construire au démarrage.
- **Justification** : l'écran lit la base à sa construction ; au démarrage, rien n'impose ce travail, et les tests de la coque n'ouvrent plus de vraie base.

### Refus du PEA

- **Décision** : le PEA est refusé avec une explication quand `pea_eligible` est faux, déjà dans le formulaire (message immédiat) puis à la validation.
- **Alternative écartée** : masquer l'option PEA.
- **Justification** : l'explication fait partie de ce que le jeu enseigne. Aucun des 30 actifs du catalogue n'est marqué éligible : le PEA est donc toujours refusé aujourd'hui (voir `limitations.md`).

### `flutter_localizations` pour le sélecteur de date

- **Décision** : dépendance `flutter_localizations` (paquet du SDK Flutter) et `GlobalMaterialLocalizations.delegates` dans `MaterialApp`, locale `fr_FR` seule.
- **Alternative écartée** : garder les textes anglais du sélecteur ; ou écrire un sélecteur de date maison.
- **Justification** : sans ces délégués, `showDatePicker` plante en français (« No MaterialLocalizations found »). Le paquet est fourni avec Flutter : rien n'est téléchargé d'un tiers.

### Barre de navigation « liquid glass »

- **Décision** : dépendance `liquid_glass_renderer` (version préliminaire `1.0.0-dev.2`) pour la barre du bas. Flutter GPU activé dans `Info.plist` (iOS, macOS) et `AndroidManifest.xml`. La barre flotte au dessus des pages dans un `Stack` de `HomeShell`, qui réduit d'autant le `MediaQuery.padding` des pages.
- **Alternative écartée** : `BackdropFilter` + dégradé translucide (sans dépendance, mais sans réfraction) ; `NavigationBar` Material.
- **Justification** : seul le rendu par shader reproduit la réfraction du verre iOS. Le paquet bascule seul sur un verre dépoli (`FakeGlass`) quand Flutter GPU est indisponible : la barre reste utilisable partout. Limite : paquet en préversion, à valider sur appareil réel avant la soutenance.

### Formulaire de simulation guidé

- **Décision** : le formulaire suit trois étapes numérotées (actif, montant, période), chacune avec une phrase d'aide en langage courant. Montants rapides (puces) et durées rapides (1, 3, 5 ans, tout l'historique) en plus de la saisie libre et des sélecteurs de date. Enveloppe et frais sont rangés dans « Options (facultatif) », repliés par défaut, avec un résumé (« Compte titres · sans frais ») et des valeurs par défaut sûres. Une ligne indique la prochaine étape à remplir.
- **Alternative écartée** : bouton « Calculer » désactivé tant que le formulaire est incomplet ; assistant en plusieurs écrans.
- **Justification** : un débutant ne sait pas quoi taper pour les frais ou l'enveloppe. Les valeurs par défaut permettent de calculer en trois gestes. Le bouton reste actif pour que le message d'erreur explique ce qui manque, plutôt qu'un bouton grisé sans raison. Seule la présentation change : le contrôleur et le domaine sont intacts.

## Jeu : « Expliquer la réponse »

### Explication à la demande, en trois parties

- **Décision** : après la révélation d'une manche, un bouton « Expliquer la réponse » ouvre une carte (état `explainedRounds` du `GameController`, comme le faisait l'ancien état de l'indice). Elle contient : (1) le régime de la période (calme, agitée, crise) calculé par `analyzeWindow` dans `domain/window_regime.dart` sur les 30 semaines ; (2) les événements réels de `assets/market_events.json` qui recoupent la période ; (3) des conseils de comportement adaptés au régime.
- **Alternative écartée** : afficher l'explication automatiquement à la révélation ; générer une cause à partir des seuls chiffres.
- **Justification** : l'utilisateur veut choisir quand lire. Les chiffres disent comment le marché a bougé, jamais pourquoi : pour le pourquoi, il faut des faits datés et sourcés. Les cas calmes et agités sont expliqués au même titre que les crises, pour ne pas laisser croire que seule une crise justifie un mouvement.

### Régime de la période : seuils éditoriaux

- **Décision** : crise si la baisse maximale atteint 20 %, agitée si elle atteint 10 % ou si la volatilité annualisée (rendements hebdomadaires, √52) atteint 30 %, calme sinon. Pour une crypto, les trois seuils sont doublés. Tendance « stable » dans ±5 %. Constantes nommées dans `window_regime.dart`, testées aux bornes.
- **Alternative écartée** : seuils relatifs à l'historique de chaque actif ; un seul jeu de seuils pour tous les actifs.
- **Justification** : −10 % (correction) et −20 % (marché baissier) sont les conventions courantes ; la volatilité de 30 % et le doublement pour les cryptos sont des choix pédagogiques, notés dans `docs/limitations.md`. Un seuil relatif serait plus juste mais plus difficile à expliquer à un jury.

### Événements : fichier embarqué, sourcé, hors connexion

- **Décision** : `assets/market_events.json`, lu comme `earnings.json` (DTO tolérant, ligne invalide ignorée, fichier illisible = pas d'explication mais le jeu continue). Chaque événement porte période, résumé, types d'actifs concernés et au moins une source (sans source, il est écarté). Un tirage attache à chaque manche au plus 3 événements, ceux qui couvrent le plus de jours. Les résultats d'entreprise viennent de `earnings.json`, annonces masquées comprises, car l'explication n'arrive qu'après la réponse.
- **Alternative écartée** : récupérer l'actualité par API (hors connexion impossible, plan payant) ; écrire les événements de mémoire.
- **Justification** : exigence de démonstration hors connexion et règle « ne jamais inventer ». Chaque fait (taux, dates, montants) a été relu sur la page officielle citée (Fed, SEC, OMS, Maison-Blanche, communiqué Nvidia) ou, à défaut, sur Wikipédia ou la presse, indiqué dans la source. Aucune nouvelle dépendance : pas d'ouverture de lien, l'adresse s'affiche en texte sélectionnable.

### Dates de résultats : SEC EDGAR, gratuit

- **Décision** : `tool/fetch_sec_earnings.py` récupère, pour les 16 actions du catalogue autres qu'Apple, les dépôts 8-K contenant l'item 2.02 (résultats) auprès d'EDGAR (`data.sec.gov`), depuis octobre 2021, et les écrit dans `assets/earnings.json` (champ `source`). Les lignes d'Apple, qui ont l'écart avec les attentes (Twelve Data), sont conservées. Le script s'exécute à la main, hors de l'app : l'app ne lit toujours que le fichier embarqué.
- **Alternative écartée** : plan Twelve Data Grow (payant, seule source gratuite de l'écart avec les attentes) ; dates saisies de mémoire (interdit).
- **Justification** : contrainte « tout reste gratuit ». EDGAR est officiel, sans clé ni compte ; il exige seulement un contact dans le `User-Agent` et moins de 10 requêtes par seconde (0,25 s d'attente). Le contact est passé en argument et n'est jamais écrit dans le dépôt. Sans écart, la carte dit « résultats publiés le … » : `surprise_prc` est facultatif dans le DTO.

## Jeu : contexte avant la réponse

### L'actif n'est plus mystère

- **Décision** : avant de parier, le joueur voit le nom de l'entreprise, son type, sa description, la période des 26 semaines affichées, le régime de ces semaines (calme, agitée, crise, calculé sur les semaines visibles seulement), les événements du monde en cours, les annonces de résultats déjà publiées et des conseils pour ce type de marché (`ContextCard`). Le bouton « Voir un indice » et le mode indice sont supprimés.
- **Alternative écartée** : garder l'actif anonyme et ne montrer que le contexte du marché ; garder l'indice à côté de la carte.
- **Justification** : demande explicite de laisser au joueur une vraie chance de bien choisir. L'indice devenait redondant : les annonces sont maintenant listées avec leur date. Cela change le cahier des charges (section 7.3 : « sans nom ni dates »). Le score reste comparé au hasard et à « toujours hausse », car 4 semaines restent imprévisibles : le contexte aide à réfléchir, il ne garantit rien, et la carte le dit.

### Ne rien révéler des semaines masquées

- **Décision** : chaque événement a des jalons datés (`milestones`) et un `mechanism` (comment les marchés lisent ce type d'événement, sans dire ce que le cours a fait ensuite). Avant la réponse, la carte montre les jalons datés avant le premier jour masqué (`GameRound.hiddenStart`, `milestonesBefore`) et le mécanisme, jamais le récit complet (`summary`, réservé à « Expliquer la réponse »). `GameRound.contextEvents` ne contient que les événements commencés avant la première semaine masquée ; `visibleEarnings` que les annonces antérieures. `drawRounds` les calcule en domaine, testés aux bornes (jour de début de la semaine masquée exclu).
- **Alternative écartée** : filtrer dans le Widget ; ne pas afficher les événements qui dépassent la période visible.
- **Justification** : un événement comme celui des droits de douane d'avril 2025 s'étend sur la période visible et la période masquée. Découper en jalons datés permet de montrer ce qui était connu sans donner la réponse. Le filtre est dans le domaine, donc testable sans écran. Les dates des événements du fichier ont été avancées au premier jalon vérifié (SVB : 12 mars 2023, chute d'août 2024 : 2 août).

