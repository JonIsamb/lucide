import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // French month names ("5 octobre") must be loaded before any DateFormat.
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';

  // Load the glass shaders now so the navigation bar is glass from frame 1.
  await LiquidGlass.precache();

  // ProviderScope stores the state of every Riverpod provider.
  runApp(const ProviderScope(child: LucideApp()));
}
