import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/glass_nav_bar.dart';
import 'features/catalog/presentation/catalog_screen.dart';
import 'features/game/presentation/game_screen.dart';
import 'features/home/home_screen.dart';
import 'features/simulator/simulator_screen.dart';

class LucideApp extends StatelessWidget {
  const LucideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('fr', 'FR'),
      // French labels for the date picker and other Material widgets.
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('fr', 'FR')],
      home: const HomeShell(),
    );
  }
}

/// The 4 main tabs with a bottom navigation bar.
///
/// IndexedStack keeps every tab alive, so the catalogue keeps its scroll
/// position and search text when the user visits another tab and comes back.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  /// The game draws its rounds from the stored prices when it is built.
  /// Building it only once its tab is opened gives the catalogue time to
  /// download them on the first launch.
  bool _gameOpened = false;

  /// Same for the simulator: it reads the database when it is built.
  bool _simulatorOpened = false;

  void _select(int index) => setState(() {
    _index = index;
    if (index == _gameTab) _gameOpened = true;
    if (index == _simulatorTab) _simulatorOpened = true;
  });

  static const _simulatorTab = 2;
  static const _gameTab = 3;

  @override
  Widget build(BuildContext context) {
    // The bar floats at the bottom: pages stop above it so no button or
    // list end is hidden behind the glass.
    final media = MediaQuery.of(context);
    final barSpace =
        GlassNavBar.height + 12 + math.max(media.padding.bottom, 8);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: barSpace),
              child: IndexedStack(
                index: _index,
                children: [
                  HomeScreen(onOpenTab: _select),
                  const CatalogScreen(),
                  if (_simulatorOpened)
                    const SimulatorScreen()
                  else
                    const SizedBox.shrink(),
                  if (_gameOpened)
                    GameScreen(onGoHome: () => _select(0))
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassNavBar(
              selectedIndex: _index,
              onSelected: _select,
              items: const [
                GlassNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Accueil',
                ),
                GlassNavItem(
                  icon: Icons.trending_up_rounded,
                  selectedIcon: Icons.trending_up_rounded,
                  label: 'Catalogue',
                ),
                GlassNavItem(
                  icon: Icons.calculate_outlined,
                  selectedIcon: Icons.calculate_rounded,
                  label: 'Simulations',
                ),
                GlassNavItem(
                  icon: Icons.casino_outlined,
                  selectedIcon: Icons.casino_rounded,
                  label: 'Jeu',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
