import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../catalog/presentation/catalog_controller.dart';
import '../catalog/presentation/widgets/favorite_button.dart';
import '../catalog/presentation/widgets/status_messages.dart';
import '../simulator/simulator_screen.dart';
import 'domain/chart_period.dart';
import 'presentation/asset_detail_controller.dart';
import 'presentation/asset_detail_state.dart';
import 'presentation/widgets/detail_card.dart';
import 'presentation/widgets/detail_header.dart';
import 'presentation/widgets/detail_skeleton.dart';
import 'presentation/widgets/indicator_card.dart';
import 'presentation/widgets/markers_card.dart';
import 'presentation/widgets/period_selector.dart';
import 'presentation/widgets/price_chart.dart';

/// The asset detail screen ("fiche actif"). It only displays
/// [AssetDetailState] and forwards the user's actions to
/// [AssetDetailController].
class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = assetDetailControllerProvider(symbol);
    final detail = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    // The star has one owner, the catalogue: both screens always agree.
    final isFavorite = ref.watch(
      catalogControllerProvider.select(
        (catalog) =>
            catalog.value?.assets.any(
              (a) => a.symbol == symbol && a.isFavorite,
            ) ??
            false,
      ),
    );

    final Widget body;
    var showsSimulatorButton = false;
    switch (detail) {
      case AsyncData(:final value) when value.detail.hasPrices:
        showsSimulatorButton = true;
        body = _DetailBody(
          state: value,
          onPeriodSelected: controller.setPeriod,
          onRefresh: () => controller.refresh(force: true),
        );
      case AsyncData(:final value) when value.isRefreshing:
        body = const DetailSkeleton();
      case AsyncData():
        // Nothing stored and nothing downloaded: the provider has no data.
        body = _ErrorBody(
          title: 'Cours indisponible',
          message: 'Aucun cours n’a pu être chargé pour cet actif.',
          onRetry: controller.retry,
        );
      case AsyncError(:final error):
        body = _ErrorBody(
          title: 'Impossible de charger la fiche',
          message: error is ApiException
              ? error.userMessage
              : 'Une erreur inattendue est survenue.',
          onRetry: controller.retry,
        );
      default:
        body = const DetailSkeleton();
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              assetName: detail.value?.detail.instrument.name ?? symbol,
              isFavorite: isFavorite,
              onFavoritePressed: () => ref
                  .read(catalogControllerProvider.notifier)
                  .toggleFavorite(symbol),
            ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: showsSimulatorButton
          ? const _SimulatorButton()
          : null,
    );
  }
}

/// Round back button on the left, favorite star on the right.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.assetName,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  final String assetName;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: 'Retour au catalogue',
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(Icons.chevron_left_rounded, size: 28),
              color: AppColors.ink,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: FavoriteButton(
              isFavorite: isFavorite,
              assetName: assetName,
              onPressed: onFavoritePressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.state,
    required this.onPeriodSelected,
    required this.onRefresh,
  });

  final AssetDetailState state;
  final ValueChanged<ChartPeriod> onPeriodSelected;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final currency = detail.instrument.currency;
    final candles = state.periodCandles;
    final stats = state.stats;
    final refreshError = state.refreshError;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        // Pull-to-refresh must work even when the content is short.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          DetailHeader(
            detail: detail,
            period: state.period,
            change: stats.changePercent,
            isRefreshing: state.isRefreshing,
          ),
          if (refreshError != null) ...[
            const SizedBox(height: 12),
            OfflineBanner(
              error: refreshError,
              lastUpdate: detail.lastFetchedAt,
            ),
          ],
          const SizedBox(height: 14),
          PeriodSelector(
            selected: state.period,
            changes: state.changeByPeriod,
            onSelected: onPeriodSelected,
          ),
          const SizedBox(height: 12),
          DetailCard(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: PriceChart(
              candles: candles,
              points: state.chartPoints,
              currency: currency,
              color: trendColor(stats.changePercent),
              drawdown: stats.drawdown,
            ),
          ),
          const SizedBox(height: 12),
          IndicatorCard(stats: stats, candles: candles, currency: currency),
          const SizedBox(height: 12),
          MarkersCard(stats: stats, currency: currency),
          const SizedBox(height: 12),
          const Text(
            'Indicateurs calculés sur des cours hebdomadaires, non ajustés '
            'des dividendes : la performance des actifs qui en versent est '
            'sous-estimée.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CatalogMessage(
        icon: Icons.cloud_off_rounded,
        title: title,
        message: message,
        buttonLabel: 'Réessayer',
        onPressed: onRetry,
      ),
    );
  }
}

/// Fixed button at the bottom, leading to the simulator.
class _SimulatorButton extends StatelessWidget {
  const _SimulatorButton();

  void _openSimulator(BuildContext context) {
    // The simulator is not built yet: its placeholder is shown for now.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
          ),
          body: const SimulatorScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: FilledButton.icon(
          onPressed: () => _openSimulator(context),
          icon: const Icon(Icons.calculate_outlined, size: 20),
          label: const Text('Ce que j’aurais vraiment gagné'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
