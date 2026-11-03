
# CLAUDE.md : Investment Companion (Flutter)

## 1. Contexte

Projet INSA Hauts de France, FISA Informatique 5e année, module Compilation et Développement d'Applications Mobiles.
Application Flutter pédagogique pour un investisseur débutant. Aucune transaction réelle, aucune connexion bancaire ou courtier.

Promesse produit : montrer ce qu'un investissement rapporte vraiment (après change, frais, impôt, inflation) et prouver par le jeu que personne ne prédit une courbe à court terme.

Le livrable est noté sur : architecture, gestion des états, persistance, cache, hors connexion, calculs métier testés, animations codées, rapport justifiant chaque choix. Une démonstration hors connexion aura lieu après fermeture complète de l'app et coupure du réseau. Le jury pourra demander une modification de code en direct : tout le code doit rester lisible et explicable.

## 2. Règles de travail pour Claude

* Avant toute modification, lire les fichiers concernés et respecter l'architecture de la section 4. Ne jamais placer de logique métier, d'appel réseau ou d'accès base dans un Widget.
* Le dossier `domain/` est du Dart pur : aucun import de `package:flutter`, de `drift`, de `http`. Toute fonction de calcul y est pure, déterministe, testée.
* Chaque nouvelle fonction métier arrive avec ses tests unitaires, cas limites inclus (section 9). Pas de fusion sans `flutter test` vert et `flutter analyze` sans avertissement.
* Ne jamais inventer une règle fiscale, un taux, un endpoint ou une limite de quota. Si une donnée n'est pas dans ce fichier ou dans la documentation officielle, le signaler et demander.
* Toute hypothèse simplificatrice (cours non ajustés des dividendes, jours fériés ignorés, inflation estimée) est notée dans `docs/limitations.md`, qui alimente le rapport.
* Après chaque fonctionnalité terminée, mettre à jour `docs/decisions.md` : décision, alternative écartée, justification. Ce fichier sert de base au rapport.
* Code et identifiants en anglais, textes affichés et documentation en français.
* Pas de nouvelle dépendance sans justification écrite dans `docs/decisions.md`.

## 3. Pile technique

| Rôle                | Choix                                                                     | Justification courte                                                         |
| -------------------- | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| États               | `flutter_riverpod` (Notifier, AsyncNotifier), sans générateur de code | état hors de l'arbre de Widgets, testable sans UI, explicable en soutenance |
| Persistance et cache | `drift` + `drift_flutter` (SQLite)                                    | requêtes typées, migrations, tests sur base en mémoire                    |
| Réseau              | `http` + client maison avec limiteur de débit                          | dépendance minimale, contrôle total des erreurs                            |
| Graphiques           | `fl_chart`                                                              | courbes de prix                                                              |
| Navigation           | `go_router`                                                             | routes déclaratives, paramètres typés                                     |
| Formatage            | `intl` (locale fr_FR)                                                   | nombres, devises, dates                                                      |
| Tests                | `flutter_test`, `mocktail`                                            | doublures des dépôts et clients API                                        |

Commandes :

```
flutter pub get
dart run build_runner build -d
flutter analyze
flutter test
dart format .
```

Clés API : fichier `lib/core/config/secrets.dart` exclu du dépôt via `.gitignore`, modèle versionné `secrets.example.dart`. Limite connue à noter dans le rapport : une clé embarquée dans une app mobile reste extractible.

## 4. Architecture

Organisation par fonctionnalité, trois couches par fonctionnalité.

```
lib/
  main.dart
  app/                    router, thème, ProviderScope
  core/
    config/               secrets, constantes
    network/              ApiClient, RateLimiter, ApiException
    database/             AppDatabase drift, tables, migrations
    time/                 Clock injectable (jamais DateTime.now() en dur)
    widgets/              composants partagés (FreshnessBadge, ErrorView)
  features/
    catalog/
      data/               dto, sources distantes, dépôt
      domain/             entités, calculs (volatility, max_drawdown, variation)
      presentation/       notifiers, écrans, widgets
    real_return/
      data/
      domain/             cascade, fiscal_rules_2026, fisher
      presentation/
    guess_game/
      data/
      domain/             tirage des manches, score, statistique binomiale
      presentation/
test/                     miroir de lib/
docs/                     decisions.md, limitations.md, cache.md
assets/seed/              jeu de données initial (section 6.4)
```

Réponses attendues aux questions du jury (à garder vraies dans le code) :

* État de l'application : dans les Notifiers Riverpod, jamais dans les Widgets sauf état purement visuel (contrôleurs d'animation, focus).
* Décision cache ou API : uniquement dans les dépôts (`*Repository`). Les Notifiers ignorent l'origine des données.
* Calculs métier : uniquement dans `domain/`.
* Persistance : uniquement dans les DAO drift, appelés par les dépôts.
* Propagation des erreurs : source lève une `ApiException` typée, le dépôt la convertit en résultat porteur de fraîcheur, le Notifier l'expose via `AsyncValue`, le Widget l'affiche.
* Reconstruction d'un Widget : aucun effet de bord dans `build`, aucun appel réseau relancé, les providers conservent l'état.

## 5. États

Type commun retourné par les dépôts :

```dart
class Fresh<T> {
  final T data;
  final DateTime lastUpdated;   // date de la dernière donnée obtenue du réseau
  final DataOrigin origin;      // network, cache, seed
  final bool isStale;           // calculé par FreshnessPolicy
}
```

Six états affichés sur la fiche actif, tous dérivés de `AsyncValue<Fresh<PriceSeries>>` :

| État                | Condition                       | Affichage                                         |
| -------------------- | ------------------------------- | ------------------------------------------------- |
| initial              | aucun symbole sélectionné     | invitation                                        |
| chargement           | `isLoading` sans valeur       | squelette                                         |
| données             | valeur présente, pas d'erreur  | graphique + badge de fraîcheur                   |
| actualisation        | `isRefreshing` avec valeur    | graphique + indicateur discret                    |
| erreur avec cache    | erreur avec valeur précédente | graphique + bandeau « données du JJ/MM HH:mm » |
| erreur sans données | erreur sans valeur              | message + bouton réessayer                       |

États métier à gérer explicitement : favori ou non, simulation non configurée, invalide, calculée, sauvegardée ; partie de jeu non commencée, en cours, manche révélée, terminée ; cache vide pour le jeu.

Règle de fraîcheur (`FreshnessPolicy`, testée) :

* actions et ETF : périmé au delà de 3 jours de bourse sans nouvelle clôture (samedi et dimanche exclus, jours fériés américains ignorés, limite documentée) ;
* cryptos : périmé au delà de 2 jours calendaires (marché ouvert 7 jours sur 7).

## 6. Données, API et cache

### 6.1 Sources

* Twelve Data : séries quotidiennes actions et ETF. Quota gratuit annoncé : 8 crédits par minute, 800 par jour. À revérifier avant usage.
* Cryptos : vérifier avant implémentation la profondeur d'historique du plan gratuit CoinGecko. Si elle est inférieure à 5 ans, utiliser Twelve Data pour les paires crypto en USD et documenter ce choix.
* Frankfurter : taux EUR/USD historiques (pas de cotation samedi et dimanche : prendre le dernier taux disponible antérieur).
* Banque mondiale : inflation annuelle France, indicateur `FP.CPI.TOTL.ZG`. Les années récentes peuvent manquer : utiliser la dernière valeur connue, marquer le résultat comme estimé dans l'interface.
  Toutes les séries de prix sont stockées en USD pour que l'étape change de la cascade soit identique pour tous les actifs.

Chaque réponse JSON est convertie en DTO (`fromJson` explicite), puis en entité du domaine. Les champs numériques arrivent parfois en chaînes : conversion défensive, valeur invalide signalée et ignorée, jamais un plantage.

### 6.2 Tables drift

* `assets` : symbol, name, type (stock, etf, crypto), currency, pea_eligible, exchange
* `price_bars` : symbol, day, open, high, low, close, volume ; clé primaire (symbol, day)
* `sync_state` : symbol, provider, last_bar_day, last_fetch_at, requests_today, requests_day
* `fx_rates` : day, eur_usd
* `inflation` : year, rate, is_estimate
* `favorites` : symbol, added_at
* `simulations` : id, paramètres complets, résultat figé (JSON), created_at
* `game_sessions` : id, started_at, finished_at, score, hint_mode
* `game_rounds` : session_id, index, symbol, start_day, answer, correct
  Données utilisateur (favorites, simulations, game_*) et données réseau (price_bars, fx_rates, inflation, sync_state) sont dans des DAO séparés : la purge du cache ne touche jamais les données utilisateur.

### 6.3 Stratégie de cache (à expliquer dans le rapport)

1. Ouverture d'une fiche : lecture immédiate du cache, affichage, puis décision de rafraîchir.
2. Rafraîchir seulement si `last_bar_day` est antérieur à la dernière clôture attendue selon `FreshnessPolicy`.
3. Requête incrémentale à partir de `last_bar_day` moins 1 jour (recouvrement d'un jour).
4. Si la clôture du jour de recouvrement diffère de plus de 0,5 % de la valeur en cache, une division d'actions est suspectée : purge de la série du symbole, téléchargement complet.
5. Écriture des barres en transaction unique, puis mise à jour de `sync_state`.
6. `RateLimiter` à jeton : 8 requêtes par minute, compteur journalier persisté ; au delà, aucune requête, état erreur avec cache.
7. Le catalogue n'appelle jamais l'API en masse : il affiche la dernière clôture en cache. Aucun chargement automatique des 30 actifs.

### 6.4 Jeu de données initial

`assets/seed/` contient un historique hebdomadaire de 5 ans pour les 30 actifs, importé en base au premier lancement avec `origin = seed`. Rôles : jeu jouable dès le premier lancement, démonstration hors connexion garantie. Les données réseau remplacent ensuite le seed.

## 7. Fonctionnalités

### 7.1 Catalogue et fiche actif

* Liste des 30 actifs depuis la base locale, recherche, filtre par type, tri, favoris avec animation.
* Fiche : graphique 1 mois, 6 mois, 1 an, 5 ans ; variation sur la période ; volatilité annualisée ; baisse maximale. Chaque indicateur porte une phrase d'explication pour débutant.
* Volatilité : écart type des rendements quotidiens simples, multiplié par racine de 252 pour actions et ETF, racine de 365 pour cryptos. Choix documenté.
* Baisse maximale : plus forte baisse entre un sommet et le point bas suivant (annexe A.2 du sujet).
* Limite à afficher et documenter : cours non ajustés des dividendes, donc performance des ETF distribuants sous estimée.

### 7.2 Ce que j'aurais vraiment gagné

Formulaire validé :

* actif obligatoire ; montant strictement positif ;
* date d'achat antérieure à la date de vente, toutes deux dans l'historique disponible ; un jour sans cotation prend la dernière clôture antérieure ;
* enveloppe compte titres ou PEA ; PEA refusé avec explication si `pea_eligible` est faux (actions et ETF américains, cryptos) ;
* frais de courtage (montant ou pourcentage) et frais annuels en pourcentage, bornés.
  Cascade, ordre fixe, chaque barre égale à l'écart entre deux performances cumulées successives (la somme des barres égale le résultat final par construction, à tester) :

1. performance brute en USD : prix de vente / prix d'achat, moins 1 ;
2. effet change : performance en EUR avec taux Frankfurter aux deux dates, moins performance USD ;
3. frais : courtage à l'achat et à la vente, frais annuels au prorata de la durée ;
4. impôt : base égale au produit net de vente moins coût d'acquisition frais inclus ; base négative ou nulle, impôt nul ;
5. inflation : rendement réel par la relation de Fisher, (1 + nominal) / (1 + inflation cumulée), moins 1 ; années partielles au prorata composé.
   Règles fiscales dans `domain/fiscal_rules_2026.dart`, une constante par taux, avec date d'effet et source en commentaire :

* compte titres : 31,4 % ;
* PEA détenu 5 ans ou plus : 18,6 % ;
* PEA détenu moins de 5 ans : 31,4 % ;
* cryptos : 31,4 %, sauf total des cessions de l'année inférieur ou égal à 305 € (la simulation ne connaît qu'une cession : hypothèse documentée) ;
* option pour le barème progressif hors périmètre, documenté.
  Résultat : phrase du type « +20 % annoncés, +3,7 % gagnés en pouvoir d'achat », compteur animé. Sauvegarde avec paramètres et résultat figés : une simulation relue n'est jamais recalculée avec des données plus récentes.

### 7.3 Teste ton intuition

* Manche : fenêtre de 26 semaines tirée au hasard parmi les séries hebdomadaires en base, sans nom ni dates, normalisée base 100. Le joueur parie hausse ou baisse sur les 4 semaines suivantes.
* Tirage dans `domain/`, avec générateur aléatoire injectable (graine fixe en test). Une fenêtre exige 30 semaines consécutives disponibles.
* Révélation : la suite se trace point par point, puis l'actif et la période apparaissent.
* Partie de 10 manches. Affichage du score avec deux références calculées sur les mêmes manches : le hasard (entre 2 et 8 bonnes réponses, score compatible avec une pièce au seuil de 5 %, bornes calculées par `chanceBounds`) et la stratégie « toujours hausse ». Le message final compare le joueur aux deux.
* Mode indice : annonces de résultats trimestriels publiées pendant les 26 semaines visibles (« il y a N semaines, meilleurs ou moins bons que prévu »), sans nom ni date, jamais celles des 4 semaines masquées. Données embarquées dans `assets/earnings.json` (format `/earnings` de Twelve Data, plan Grow requis pour le compléter : ne jamais saisir une date de mémoire). Pas de pénalité de score.
* Cache vide et seed absent : état métier explicite, jeu indisponible avec explication.

## 8. Animations (au moins deux codées)

| Animation                  | Mécanisme                                                                       | Statut    |
| -------------------------- | -------------------------------------------------------------------------------- | --------- |
| Cascade du rendement réel | `CustomPainter` + `AnimationController` + `Tween` décalés (`Interval`) | codée    |
| Compteur du résultat      | `Tween<double>` + `AnimatedBuilder`                                          | codée    |
| Révélation de la courbe  | `AnimationController` pilotant le nombre de points tracés                     | codée    |
| Ajout aux favoris          | `AnimatedSwitcher` ou `ScaleTransition`                                      | implicite |

Chaque `AnimationController` est créé dans `initState` et libéré dans `dispose`, avec `TickerProviderStateMixin`. Aucun contrôleur dans un Notifier.

## 9. Tests

Priorité absolue sur `domain/`. Cas obligatoires :

* performance, variation, volatilité, baisse maximale : série vide, un seul point, prix nul, série constante, exemple de l'annexe A.2 (100, 110, 125, 115, 90, 105 donne une baisse de 28 %) ;
* cascade : somme des barres égale au total, perte sans impôt, durée PEA exactement 5 ans, seuil crypto 305 € et 306 €, inflation manquante, dates inversées refusées ;
* Fisher : inflation nulle, inflation négative ;
* jeu : tirage déterministe avec graine, fenêtre impossible, bornes binomiales 1, 2, 8, 9 (10 manches) et 5, 6, 14, 15 (20 manches) ;
* FreshnessPolicy : vendredi soir, lundi matin, crypto le dimanche ;
* cache : base drift en mémoire, requête incrémentale correcte, détection de division, quota atteint ;
* conversion JSON : champ manquant, nombre en chaîne, valeur invalide.

## 10. Ordre de livraison

1. Socle : base drift, seed, client API, limiteur, dépôt de prix avec cache, tests du cache.
2. Catalogue et fiche, six états, indicateurs et tests.
3. Hors connexion vérifié en conditions de soutenance.
4. Jeu (dépend seulement des données en cache).
5. Rendement réel, cascade, fiscalité, tests.
6. Animations, finitions, `docs/` complet pour le rapport.
   Un module non terminé ne doit jamais casser la démonstration des modules terminés.
