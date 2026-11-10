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
- **(Obsolète, voir plus bas) Indice : données pour Apple seulement.** `assets/earnings.json` contient les 24 annonces de résultats d'Apple (octobre 2020 à juillet 2026), obtenues de Twelve Data. Les 16 autres actions du catalogue demandent le plan Grow : elles ne sont pas dans le fichier, et aucune date n'a été saisie de mémoire. Pour elles, comme pour les ETF et les cryptos, l'indice affiche « Aucune annonce de résultats connue sur ces semaines ».
- **(Supprimé) L'indice peut trahir l'actif.** Le mode indice n'existe plus : l'actif est affiché avant la réponse. Tant qu'un seul actif a des annonces, un indice non vide désigne Apple. Avec le fichier complet, il dira seulement « c'est une action ».
- **(Supprimé) Indice sans effet sur le score.** L'indice demandé est mémorisé par manche, mais ni pénalité ni affichage au bilan.
- **Écart au consensus brut.** « Meilleurs » ou « moins bons que prévu » suit seulement le signe de `surprise_prc` (bénéfice par action publié contre attendu). Aucun seuil : +0,1 % compte comme « meilleurs ».
- **Annonce après la clôture.** Une annonce publiée après la clôture est rattachée à la semaine de son jour ; si ce jour est le dernier de la semaine affichée, la réaction du cours tombe dans la première semaine masquée.
- **Référence « toujours hausse » absente.** Le bilan compare le score au hasard seulement.
- **Cours inchangé compté comme « plus bas ».** Si le cours après 4 semaines est exactement égal au dernier cours visible, la bonne réponse est « plus bas » (le cours n'est pas plus haut).
- **Échelle horizontale de la zone masquée.** Les 4 semaines masquées occupent plus de largeur par semaine que les 26 semaines visibles, pour rester lisibles. La pente de la suite révélée paraît donc plus douce qu'elle ne l'est.
- **Échelle verticale.** Pendant la manche, l'échelle ne tient compte que des semaines visibles, pour ne pas trahir la réponse ; elle s'élargit pendant la révélation.

## Simulation « Ce que j'aurais vraiment gagné »

- **Prix hebdomadaires.** Seules des clôtures hebdomadaires sont en base. Un jour choisi prend la clôture de la dernière bougie commencée ce jour-là ou avant : pour un jour de milieu de semaine, c'est la clôture du vendredi suivant, donc légèrement postérieure au jour choisi. Les dates sont bornées au premier jour de la première bougie et à six jours après le début de la dernière.
- **Aucun actif éligible au PEA.** Les 30 actifs du catalogue ont `peaEligible: false` (actions et ETF américains, cryptos). Le calcul du PEA (taux réduit après 5 ans exactement) est implémenté et testé, mais l'option est toujours refusée dans l'application.
- **PEA de moins de 5 ans.** Le taux de 31,4 % du cahier des charges est appliqué ; les effets d'une clôture anticipée du plan ne sont pas modélisés.
- **Cryptos : une seule cession.** Le seuil de 305 € s'applique à cette cession seule ; les autres ventes de l'année ne sont pas connues. Les cryptos du catalogue sont cotées en euros : aucun effet de change.
- **Change.** Seuls EUR et USD existent. Un actif en euros n'a pas d'effet de change ; un actif en dollars utilise le taux Frankfurter du jour, ou du dernier jour de cotation antérieur (week-ends, jours fériés). Les cours ne sont pas convertis jour par jour : seuls les taux aux deux dates comptent.
- **Option pour le barème progressif** hors périmètre : seul le prélèvement forfaitaire est simulé.
- **Frais.** Courtage identique à l'achat et à la vente (montant fixe, ou pourcentage du montant investi à l'achat et du produit brut à la vente). Frais annuels proratisés sur le montant investi, base 365 jours. Bornes choisies pour la pédagogie, pas issues d'une règle : courtage jusqu'à 5 % (ou jusqu'au montant investi s'il est en euros), frais annuels de 0 à 5 %.
- **Base d'imposition.** Produit net de vente (après frais de vente et frais annuels) moins coût d'acquisition frais d'achat inclus. Pas de report des moins-values.
- **Inflation.** Taux annuel moyen France de la Banque mondiale (`FP.CPI.TOTL.ZG`), composé par année civile, au prorata des jours pour les années partielles. Une année sans taux publié (l'année en cours, souvent l'année précédente) reprend le dernier taux connu, et le résultat est marqué « estimé ». Les données embarquées s'arrêtent à 2025 : toute simulation touchant 2026 est estimée tant que le réseau n'a pas apporté la valeur.
- **Pouvoir d'achat en euros du jour d'achat.** « Valeur réelle » = montant investi × (1 + rendement réel), exprimée en euros de la date d'achat.
- **Cours non ajustés des dividendes.** Comme sur la fiche : la performance brute des actifs distribuants est sous-estimée.
- **Taux d'impôt non revérifiés.** Ils viennent du cahier des charges et sont indiqués comme tels dans `fiscal_rules_2026.dart`.

## Jeu : explication de la réponse

- **Liste d'événements incomplète.** Une douzaine d'événements majeurs de fin 2021 à fin 2025. Beaucoup de périodes n'en recoupent aucun : la carte le dit sans inventer de cause. Rien n'est couvert après 2025 faute de source vérifiée ; à compléter avant d'utiliser des données plus récentes.
- **Coïncidence n'est pas cause.** Un événement est mis en regard d'un mouvement de prix, sans mesure de son effet. Les phrases sur la lecture des marchés (« les investisseurs redoutaient ») sont des explications courantes, pas des faits mesurés. Rappelé dans la carte.
- **Sources secondaires.** Pour l'invasion de l'Ukraine, la faillite de FTX, TerraUSD et le 5 août 2024, la source est Wikipédia ou la presse, faute de page officielle équivalente.
- **Seuils éditoriaux.** Les limites calme / agitée / crise (volatilité 30 %, doublement pour les cryptos) ne sont pas un standard financier. Seuls −10 % et −20 % suivent l'usage.
- **Régime sur 30 semaines.** L'analyse porte sur toute la manche, semaines masquées comprises, car elle n'est montrée qu'après la réponse.
- **Résultats d'entreprise.** Seul Apple figure dans `earnings.json` : les autres actifs n'ont aucune annonce dans l'explication.
- **Conseils généraux.** Principes pédagogiques (ne pas vendre dans la panique, diversifier, investir régulièrement), valables sans connaître la situation de la personne. Pas un conseil en investissement.
- **Liens non cliquables.** L'app n'embarque pas d'ouverture de lien : l'adresse de la source s'affiche et se copie.
- **Dates de résultats sans attentes.** Hors Apple, `earnings.json` vient d'EDGAR (8-K item 2.02) : la date est celle du dépôt, parfois un jour après l'annonce, et l'écart avec les attentes des analystes manque (donnée payante).
- **Dépôts 2.02 qui ne sont pas des résultats.** L'item 2.02 couvre tout communiqué financier. Les dépôts de Tesla des 5 premiers jours du trimestre (livraisons) sont écartés par une règle du script. D'autres dépôts isolés peuvent subsister (par exemple un dépôt en dehors des quatre dates trimestrielles pour JNJ ou GOOGL).
- **Exxon (XOM).** Seulement 2 dates trouvées (juillet et octobre 2026) ; la cause n'a pas été vérifiée, les autres trimestres manquent.
- **Pas d'ETF ni de crypto.** Ils ne publient pas de résultats trimestriels.

## Jeu : contexte avant la réponse

- **L'actif et la période sont connus.** Un joueur qui connaît l'histoire de la bourse peut reconnaître la période (par exemple la crise de 2022) et en déduire la suite. C'est voulu : le jeu ne prétend plus cacher l'actif. Le score se compare toujours au hasard.
- **Les semaines visibles seulement.** Le régime affiché avant la réponse porte sur les 26 semaines visibles ; celui de « Expliquer la réponse » sur les 30 semaines.
- **Jalons datés écrits à la main.** Chaque jalon vient de la source citée (Fed, SEC, OMS, Maison-Blanche, Nvidia, Fortune, Wikipédia). Le `mechanism` de chaque événement est une explication courante, pas un fait mesuré.
- **Un événement qui commence dans les semaines masquées n'apparaît pas avant la réponse**, même s'il explique la suite. C'est le but : ne rien révéler.
- **Semaines de 7 jours.** La frontière entre semaines visibles et masquées suppose des semaines de 7 jours (un jour férié peut décaler une bougie d'un jour ou deux).

