import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/catalog/presentation/catalog_screen.dart';
import 'features/game/game_screen.dart';
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
  // The catalogue is the first useful screen while the others are placeholders.
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          CatalogScreen(),
          SimulatorScreen(),
          GameScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_rounded),
            label: 'Catalogue',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Simulations',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino_rounded),
            label: 'Jeu',
          ),
        ],
      ),
    );
  }
}
