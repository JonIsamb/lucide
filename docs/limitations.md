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

## Jeu « Teste ton intuition »

- **10 manches : test statistique peu sensible.** Avec 10 lancers de pièce, un score de 2 à 8 est compatible avec le hasard (test binomial bilatéral, seuil 5 %) ; seuls 0, 1, 9 et 10 en sortent (2,1 % de chances à eux quatre). Un joueur qui aurait un vrai léger avantage ne serait presque jamais détecté sur une seule partie.
- **Semaines « consécutives ».** Deux bougies séparées de plus de 10 jours sont considérées comme non consécutives (une semaine manque). Entre 7 et 10 jours, on admet une semaine décalée par un jour férié.
- **Tirage proportionnel à l'historique.** Chaque fenêtre de 30 semaines a la même chance d'être tirée : un actif avec 5 ans de cours sort plus souvent qu'un actif récent.
- **Cours non ajustés des dividendes.** Comme sur la fiche : un détachement de dividende pendant les 4 semaines masquées apparaît comme une petite baisse.
- **Pas de partie à moins de 10 manches.** Si la base contient trop peu de cours (premier lancement hors connexion, aucun seed embarqué pour l'instant), le jeu est indisponible et l'explique.
- **Contexte limité aux données en base.** À la révélation, le contexte est la description de l'actif (`catalog.json`) et deux variations calculées. L'app n'explique pas pourquoi le cours a bougé : elle n'a aucune source d'actualité.
- **Statistiques d'exemple.** « Parties jouées », « meilleur score » et « moyenne » sont des valeurs fixes (`sample_stats.dart`) : les parties ne sont pas encore enregistrées.
- **Indice : données pour Apple seulement.** `assets/earnings.json` contient les 24 annonces de résultats d'Apple (octobre 2020 à juillet 2026), obtenues de Twelve Data. Les 16 autres actions du catalogue demandent le plan Grow : elles ne sont pas dans le fichier, et aucune date n'a été saisie de mémoire. Pour elles, comme pour les ETF et les cryptos, l'indice affiche « Aucune annonce de résultats connue sur ces semaines ».
- **L'indice peut trahir l'actif.** Tant qu'un seul actif a des annonces, un indice non vide désigne Apple. Avec le fichier complet, il dira seulement « c'est une action ».
- **Indice sans effet sur le score.** L'indice demandé est mémorisé par manche, mais ni pénalité ni affichage au bilan.
- **Écart au consensus brut.** « Meilleurs » ou « moins bons que prévu » suit seulement le signe de `surprise_prc` (bénéfice par action publié contre attendu). Aucun seuil : +0,1 % compte comme « meilleurs ».
- **Annonce après la clôture.** Une annonce publiée après la clôture est rattachée à la semaine de son jour ; si ce jour est le dernier de la semaine affichée, la réaction du cours tombe dans la première semaine masquée.
- **Référence « toujours hausse » absente.** Le bilan compare le score au hasard seulement.
- **Cours inchangé compté comme « plus bas ».** Si le cours après 4 semaines est exactement égal au dernier cours visible, la bonne réponse est « plus bas » (le cours n'est pas plus haut).
- **Échelle horizontale de la zone masquée.** Les 4 semaines masquées occupent plus de largeur par semaine que les 26 semaines visibles, pour rester lisibles. La pente de la suite révélée paraît donc plus douce qu'elle ne l'est.
- **Échelle verticale.** Pendant la manche, l'échelle ne tient compte que des semaines visibles, pour ne pas trahir la réponse ; elle s'élargit pendant la révélation.
