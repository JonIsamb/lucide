# Lucide

Lucide shows a beginner investor what they would really earn, and why
nobody can predict a price chart. Flutter app, INSA Hauts-de-France,
FISA 5 INFO, 2026/2027.

## Run

The app reads two API keys at build time; they are never committed.

- `TWELVE_DATA_API_KEY` ([Twelve Data](https://twelvedata.com)): US stocks and ETFs, cryptos, logos.
- `ALPHA_VANTAGE_API_KEY` ([Alpha Vantage](https://www.alphavantage.co/support/#api-key)): the
  Euronext Paris assets (PEA-eligible), which the free Twelve Data plan does not cover.
  Without it, only those assets stay without prices.

Put both in `secrets.json` (gitignored):

```json
{"TWELVE_DATA_API_KEY": "your_key", "ALPHA_VANTAGE_API_KEY": "your_key"}
```

```sh
flutter pub get
dart run build_runner build          # generates the drift database code
flutter run --dart-define-from-file=secrets.json
```

## Tests

```sh
flutter test
```

The font (Nunito, SIL Open Font License, see `assets/fonts/OFL.txt`) is bundled so the app works offline.
