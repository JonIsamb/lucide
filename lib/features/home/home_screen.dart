import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../asset_detail/asset_detail_screen.dart';
import '../catalog/presentation/catalog_controller.dart';
import '../catalog/presentation/catalog_state.dart';
import '../catalog/presentation/widgets/asset_row.dart';
import '../catalog/presentation/widgets/catalog_card.dart';
import '../game/presentation/game_history.dart';
import '../profile/domain/profile.dart';
import '../profile/presentation/profile_controller.dart';
import '../profile/profile_screen.dart';
import '../simulator/domain/saved_simulation.dart';
import '../simulator/presentation/last_simulation.dart';
import '../simulator/presentation/simulator_controller.dart';
import 'home_texts.dart';
import 'widgets/last_simulation_card.dart';
import 'widgets/shortcut_card.dart';

/// Home tab: last simulation, shortcuts to the game and the catalogue, and
/// the user's favorites.
///
/// Everything comes from the database through providers that watch it: a
/// simulation saved or a game finished in another tab shows up here
/// without reloading. When there is nothing yet (first launch), each card
/// invites the user to the tab that fills it.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  /// Switches the bottom bar to another tab (1 catalogue, 2 simulations,
  /// 3 jeu). The tabs are owned by HomeShell, not by this screen.
  final ValueChanged<int> onOpenTab;

  static const _catalogTab = 1;
  static const _simulatorTab = 2;
  static const _gameTab = 3;

  /// How many favorites the home shows before "Tout voir".
  static const _maxFavorites = 3;

  void _openDetail(BuildContext context, String symbol) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssetDetailScreen(symbol: symbol),
      ),
    );
  }

  /// Shows [saved] in the Simulations tab, exactly as it was saved (no
  /// recalculation), then switches to that tab.
  Future<void> _openSimulation(
    BuildContext context,
    WidgetRef ref,
    SavedSimulation saved,
  ) async {
    try {
      // The tab may not be built yet: wait for its data, so it opens
      // directly on the result instead of the form.
      await ref.read(simulatorControllerProvider.future);
      if (!context.mounted) return;
      ref.read(simulatorControllerProvider.notifier).openSaved(saved);
    } on Object {
      // The tab shows its own error and retry button.
    }
    if (context.mounted) onOpenTab(_simulatorTab);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final catalog = ref.watch(catalogControllerProvider);
    final lastSimulation = ref.watch(lastSimulationProvider);
    final lastGame = ref.watch(lastPlayedGameProvider);
    final profile = ref.watch(profileControllerProvider).value ?? Profile.empty;

    // Nothing saved anywhere yet: most likely the first launch. While
    // something is still loading, we do not know, so no welcome line.
    final firstVisit =
        _readAndEmpty(lastSimulation) &&
        _readAndEmpty(lastGame) &&
        catalog.value?.assets.any((a) => a.isFavorite) == false;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          _Header(
            initials: profile.initials,
            onProfile: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.hasName ? 'Salut ${profile.firstName}' : 'Salut',
            style: textTheme.headlineMedium,
          ),
          if (firstVisit) ...[
            const SizedBox(height: 6),
            Text(
              'Bienvenue ! Explore le catalogue, fais une simulation ou teste '
              'ton intuition : tes résultats s’afficheront ici.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 16),
          switch (lastSimulation) {
            AsyncData(value: final saved?) => LastSimulationCard(
              result: saved.result,
              onDetailPressed: () => _openSimulation(context, ref, saved),
            ),
            AsyncData() => SimulationInviteCard(
              onStart: () => onOpenTab(_simulatorTab),
            ),
            AsyncError() => SimulationInviteCard(
              unreadable: true,
              onStart: () => onOpenTab(_simulatorTab),
            ),
            _ => const SimulationCardSkeleton(),
          },
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ShortcutCard(
                    icon: Icons.casino_outlined,
                    title: 'Teste ton intuition',
                    subtitle: switch (lastGame) {
                      AsyncData(:final value) => lastGameSubtitle(value),
                      _ => gameTagline,
                    },
                    background: AppColors.gameTint,
                    accent: AppColors.gameInk,
                    subtitleColor: AppColors.gameInk,
                    onTap: () => onOpenTab(_gameTab),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShortcutCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Explorer le catalogue',
                    subtitle: _catalogSubtitle(catalog.value),
                    onTap: () => onOpenTab(_catalogTab),
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
                onPressed: () => onOpenTab(_catalogTab),
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

  /// The database answered, and there is nothing.
  static bool _readAndEmpty(AsyncValue<Object?> value) =>
      value is AsyncData && value.value == null;

  static String _catalogSubtitle(CatalogState? state) {
    final count = state?.assets.length;
    return count == null
        ? 'Actions, ETF et cryptos'
        : '$count actions, ETF et cryptos';
  }
}

/// "lucide." on the left, the user's initials on the right.
class _Header extends StatelessWidget {
  const _Header({required this.initials, required this.onProfile});

  /// Empty without a profile name: the avatar then shows a person icon.
  final String initials;
  final VoidCallback onProfile;

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
        Semantics(
          button: true,
          label: 'Profil',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onProfile,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.lightGreen,
              child: initials.isEmpty
                  ? const Icon(Icons.person_rounded, color: AppColors.primary)
                  : Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
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
