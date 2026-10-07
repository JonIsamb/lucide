# Limites et hypothèses simplificatrices

Ce fichier alimente le rapport.

## Fiche actif

- **Volatilité hebdomadaire.** La consigne prévoit l'écart type des rendements quotidiens, multiplié par √252 (actions, ETF) ou √365 (cryptos). Seuls des cours hebdomadaires sont en cache : la fiche calcule l'écart type d'échantillon (division par n − 1) des rendements hebdomadaires simples, multiplié par √52, pour tous les types d'actifs. Les valeurs ne sont donc pas directement comparables à une volatilité quotidienne annualisée.
- **Période « 1 mois » en 5 points.** Une période est un nombre de bougies hebdomadaires : 5 (1 mois), 27 (6 mois), 53 (1 an), tout l'historique (5 ans). Sur 1 mois, la volatilité repose sur 4 rendements seulement.
- **« 5 ans » = tout l'historique stocké.** Si un actif a moins de 5 ans de cours, la période affichée est plus courte ; les dates sous la courbe et dans les phrases donnent le vrai début.
- **Baisse maximale sur les clôtures hebdomadaires.** Les creux atteints en cours de semaine ne sont pas vus : la baisse réelle a pu être plus forte.
- **Plus haut et plus bas en cours de semaine.** Ils utilisent les extrêmes de chaque bougie, alors que la courbe et la baisse maximale utilisent les clôtures : le « plus haut » peut dépasser le sommet tracé.
- **Seuils de la phrase de volatilité.** « Calme » sous 10 %, « modéré » de 10 à 20 %, « agité » de 20 à 40 %, « très agité » au delà. Ce sont des choix de rédaction pour un débutant, pas une norme financière.
- **Cours non ajustés des dividendes.** La performance des actions et ETF qui en versent est sous-estimée ; la mention est affichée en bas de la fiche.
- **Aucun change sur la fiche.** Les montants sont dans la devise de cotation de l'actif.
- **Volume.** Moyenne des volumes hebdomadaires fournis par Twelve Data ; absent pour les cryptos, remplacé par le nombre de semaines observées.
- **Fraîcheur.** Le point devient corail après 3 jours de bourse sans mise à jour, y compris pour les cryptos (règle existante `isStale`) ; la règle de 2 jours calendaires pour les cryptos reste à faire.
- **État « initial ».** La fiche est toujours ouverte pour un symbole : l'état « aucun symbole sélectionné » n'existe pas sur cet écran.

## Jeu « Teste ton intuition » (étape graphique)

- **Courbes fictives.** Les 20 manches viennent de `sample_rounds.dart` : des courbes inventées, générées avec une graine fixe, sous des noms neutres (« Actif exemple 3 »). Le tirage dans les séries hebdomadaires en base n'est pas encore codé.
- **Statistiques d'exemple.** « Parties jouées », « meilleur score » et « moyenne » sont des valeurs fixes : les parties ne sont pas encore enregistrées.
- **Mode indice non défini.** Le bouton « Voir un indice » est affiché mais désactivé.
- **Référence « toujours hausse » absente.** Le bilan compare le score au hasard seulement.
- **Cours inchangé compté comme « plus bas ».** Si le cours après 4 semaines est exactement égal au dernier cours visible, la bonne réponse est « plus bas » (le cours n'est pas plus haut).
- **Échelle horizontale de la zone masquée.** Les 4 semaines masquées occupent plus de largeur par semaine que les 26 semaines visibles, pour rester lisibles. La pente de la suite révélée paraît donc plus douce qu'elle ne l'est.
- **Échelle verticale.** Pendant la manche, l'échelle ne tient compte que des semaines visibles, pour ne pas trahir la réponse ; elle s'élargit pendant la révélation.
- **Jeu indisponible.** Sans aucune manche, l'écran affiche un simple message ; l'état « cache vide et seed absent » avec explication reste à faire.
