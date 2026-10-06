# Lucide

Lucide shows a beginner investor what they would really earn, and why
nobody can predict a price chart. Flutter app, INSA Hauts-de-France,
FISA 5 INFO, 2026/2027.

## Run

The app reads its Twelve Data API key at build time; the key is never committed.

```sh
flutter pub get
dart run build_runner build          # generates the drift database code
flutter run --dart-define=TWELVE_DATA_API_KEY=your_key
```

Or put `{"TWELVE_DATA_API_KEY": "your_key"}` in `secrets.json` (gitignored) and run
`flutter run --dart-define-from-file=secrets.json`.

## Tests

```sh
flutter test
```

The font (Nunito, SIL Open Font License, see `assets/fonts/OFL.txt`) is bundled so the app works offline.
