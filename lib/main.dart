import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // French month names ("5 octobre") must be loaded before any DateFormat.
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';

  // ProviderScope stores the state of every Riverpod provider.
  runApp(const ProviderScope(child: LucideApp()));
}
