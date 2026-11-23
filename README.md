# Lucide

Lucide montre à un investisseur débutant ce qu'un placement rapporte vraiment,
après change, frais, impôt et inflation, et prouve par le jeu que personne ne
prédit une courbe à court terme. Application Flutter, INSA Hauts-de-France,
FISA 5 INFO, 2026/2027. Aucune transaction réelle.

## Prérequis

- Flutter 3.47.5 (canal stable), Dart 3.13.4 ou plus récent (`sdk: ^3.13.4`).
- Android : Android SDK et un émulateur ou un téléphone (Android Studio les installe).
- iOS : macOS avec Xcode, iOS 15 minimum.
- Deux clés API gratuites (voir ci-dessous). Sans elles, l'app s'ouvre mais ne
  télécharge aucun cours.

## Clés API

L'app lit deux clés à la compilation ; elles ne sont jamais versionnées.

- `TWELVE_DATA_API_KEY` ([Twelve Data](https://twelvedata.com)) : actions et ETF
  américains, cryptos, logos.
- `ALPHA_VANTAGE_API_KEY` ([Alpha Vantage](https://www.alphavantage.co/support/#api-key)) :
  les actifs d'Euronext Paris (éligibles au PEA), que le plan gratuit de Twelve
  Data ne couvre pas. Sans cette clé, seuls ces 4 actifs restent sans cours.

Créer `secrets.json` à la racine du projet (ignoré par git) :

```json
{"TWELVE_DATA_API_KEY": "votre_cle", "ALPHA_VANTAGE_API_KEY": "votre_cle"}
```

## Installation et lancement

```sh
flutter pub get
flutter run --dart-define-from-file=secrets.json
```

Le code généré de la base drift (`*.g.dart`) est fourni. Il ne faut le
régénérer qu'après une modification des tables :

```sh
dart run build_runner build -d
```

**Android Studio** : *Run → Edit Configurations → main.dart*, champ
*Additional run args* : `--dart-define-from-file=secrets.json`. Sans cette
option, le bouton ▶ lance l'app sans clé.

**APK à installer** (plus léger que la version debug) :

```sh
flutter build apk --release --dart-define-from-file=secrets.json
# build/app/outputs/flutter-apk/app-release.apk
```

## Démonstration hors connexion

Les taux de change et l'inflation sont embarqués, mais pas les cours. Ouvrir
l'app une première fois **avec une connexion** et laisser le catalogue se mettre
à jour (environ 4 minutes : le plan gratuit de Twelve Data limite à 8 requêtes
par minute). Ensuite, l'app fonctionne entièrement hors connexion avec les
données enregistrées ; un bandeau l'indique.

## Tests

```sh
flutter analyze
flutter test
```

## Documentation

- `docs/decisions.md` : chaque choix technique, l'alternative écartée et la justification.
- `docs/limitations.md` : hypothèses simplificatrices et limites connues.
- `docs/captures/` : captures d'écran de l'application.
- `tool/fetch_sec_earnings.py` : régénère `assets/earnings.json` depuis SEC EDGAR
  (`python3 tool/fetch_sec_earnings.py --contact "Prénom Nom email"`).

La police Nunito (SIL Open Font License, voir `assets/fonts/OFL.txt`) est
embarquée pour que l'app fonctionne hors connexion.
