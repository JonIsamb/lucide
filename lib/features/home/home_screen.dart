import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../asset_detail/asset_detail_screen.dart';
import '../catalog/presentation/catalog_controller.dart';
import '../catalog/presentation/catalog_state.dart';
import '../catalog/presentation/widgets/asset_row.dart';
import '../catalog/presentation/widgets/catalog_card.dart';
import 'widgets/last_simulation_card.dart';
import 'widgets/shortcut_card.dart';

/// Home tab: last simulation, shortcuts to the game and the catalogue, and
/// the user's favorites.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  /// Switches the bottom bar to another tab (1 catalogue, 2 simulations,
  /// 3 jeu). The tabs are owned by HomeShell, not by this screen.
  final ValueChanged<int> onOpenTab;

  // @TODO Comes from the profile once there is one.
  static const _firstName = 'Jonathan';
  static const _initials = 'JI';

  /// How many favorites the home shows before "Tout voir".
  static const _maxFavorites = 3;

  void _openDetail(BuildContext context, String symbol) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssetDetailScreen(symbol: symbol),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final catalog = ref.watch(catalogControllerProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          const _Header(initials: _initials),
          const SizedBox(height: 12),
          Text('Salut $_firstName', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          // @TODO Read the last simulation from the database when the
          // simulator is done. These are the numbers of the mockup.
          LastSimulationCard(
            title: 'S&P 500, 1 000 € sur 2 ans',
            realGain: 3.7,
            nominalGain: 20,
            costs: const {
              'change': 5,
              'frais': 1.5,
              'impôt': 4.5,
              'inflation': 5.3,
            },
            onDetailPressed: () => onOpenTab(2),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ShortcutCard(
                    icon: Icons.casino_outlined,
                    title: 'Teste ton intuition',
                    // @TODO Last score from the game.
                    subtitle: 'Dernière partie : 11/20, comme une pièce',
                    background: AppColors.gameTint,
                    accent: AppColors.gameInk,
                    subtitleColor: AppColors.gameInk,
                    onTap: () => onOpenTab(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShortcutCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Explorer le catalogue',
                    subtitle: _catalogSubtitle(catalog.value),
                    onTap: () => onOpenTab(1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tes favoris',
                  style: textTheme.headlineMedium?.copyWith(fontSize: 22),
                ),
              ),
              TextButton(
                onPressed: () => onOpenTab(1),
                child: const Text('Tout voir'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...switch (catalog) {
            AsyncData(:final value) => [_buildFavorites(context, ref, value)],
            AsyncError() => const [
              _EmptyFavorites(message: 'Tes favoris sont indisponibles.'),
            ],
            _ => [
              CatalogCard(
                children: List.generate(2, (_) => const AssetRowSkeleton()),
              ),
            ],
          },
        ],
      ),
    );
  }

  Widget _buildFavorites(
    BuildContext context,
    WidgetRef ref,
    CatalogState state,
  ) {
    final favorites = state.assets.where((a) => a.isFavorite).toList();
    if (favorites.isEmpty) {
      return const _EmptyFavorites(
        message:
            'Touche l’étoile d’un actif dans le catalogue pour le '
            'retrouver ici.',
      );
    }

    final controller = ref.read(catalogControllerProvider.notifier);
    return CatalogCard(
      children: [
        for (final asset in favorites.take(_maxFavorites))
          AssetRow(
            asset: asset,
            isLoading: state.isRefreshing,
            onTap: () => _openDetail(context, asset.symbol),
            onFavoritePressed: () => controller.toggleFavorite(asset.symbol),
          ),
      ],
    );
  }

  static String _catalogSubtitle(CatalogState? state) {
    final count = state?.assets.length;
    return count == null
        ? 'Actions, ETF et cryptos'
        : '$count actions, ETF et cryptos';
  }
}

/// "lucide." on the left, the user's initials on the right.
class _Header extends StatelessWidget {
  const _Header({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(
          const TextSpan(
            text: 'lucide',
            children: [
              TextSpan(
                text: '.',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.lightGreen,
          child: Text(
            initials,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_outline_rounded, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
