import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../asset_detail/asset_detail_screen.dart';
import '../domain/asset_metrics.dart';
import 'catalog_controller.dart';
import 'catalog_state.dart';
import 'widgets/asset_row.dart';
import 'widgets/catalog_card.dart';
import 'widgets/sort_sheet.dart';
import 'widgets/status_messages.dart';
import 'widgets/type_filter_chips.dart';

/// The Catalogue tab. It only displays [CatalogState] and forwards the
/// user's actions to [CatalogController].
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  // Owned by the widget because it is tied to the text field on screen.
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CatalogController get _controller =>
      ref.read(catalogControllerProvider.notifier);

  void _clearSearch() {
    _searchController.clear();
    _controller.setQuery('');
  }

  void _openDetail(String symbol) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssetDetailScreen(symbol: symbol),
      ),
    );
  }

  Future<void> _openSortSheet(CatalogState state) async {
    final sort = await showSortSheet(context, state.sort);
    if (sort != null) _controller.setSort(sort);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogControllerProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        // The download can take minutes (rate limit), so we start it and
        // let the "Mise à jour : x/y" label show the progress instead of
        // keeping the pull spinner for that long.
        onRefresh: () async {
          unawaited(_controller.refresh(force: true));
        },
        child: ListView(
          // Pull-to-refresh must work even when the list is short.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Text(
              'Catalogue',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ...switch (catalog) {
              AsyncData(:final value) => _buildData(value),
              AsyncError(:final error) => [_buildError(error)],
              _ => _buildLoading(),
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoading() => [
    CatalogCard(children: List.generate(8, (_) => const AssetRowSkeleton())),
  ];

  Widget _buildError(Object error) {
    final message = error is ApiException
        ? error.userMessage
        : 'Une erreur inattendue est survenue.';
    return CatalogMessage(
      icon: Icons.cloud_off_rounded,
      title: 'Impossible de charger les cours',
      message: message,
      buttonLabel: 'Réessayer',
      onPressed: _controller.retry,
    );
  }

  List<Widget> _buildData(CatalogState state) {
    final visible = state.visibleAssets;
    final lastUpdate = state.lastUpdate;
    final refreshError = state.refreshError;
    final count = visible.length;

    return [
      _SearchField(
        controller: _searchController,
        onChanged: _controller.setQuery,
        onClear: _clearSearch,
      ),
      const SizedBox(height: 12),
      TypeFilterChips(
        selected: state.typeFilter,
        onSelected: _controller.setTypeFilter,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Text(
              '$count ${count > 1 ? 'actifs' : 'actif'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SortButton(sort: state.sort, onPressed: () => _openSortSheet(state)),
        ],
      ),
      if (state.showsProgress) ...[
        RefreshProgressLabel(done: state.seriesDone, total: state.seriesTotal),
        const SizedBox(height: 12),
      ],
      if (refreshError != null) ...[
        OfflineBanner(error: refreshError, lastUpdate: lastUpdate),
        const SizedBox(height: 12),
      ],
      if (visible.isEmpty)
        CatalogMessage(
          icon: Icons.search_off_rounded,
          title: 'Aucun actif ne correspond à « ${state.query.trim()} »',
          buttonLabel: 'Effacer la recherche',
          onPressed: _clearSearch,
        )
      else
        CatalogCard(
          children: [
            for (final asset in visible)
              AssetRow(
                // The key keeps each row's star animation with its asset
                // when the sort order changes.
                key: ValueKey(asset.symbol),
                asset: asset,
                isLoading: state.isRefreshing,
                onTap: () => _openDetail(asset.symbol),
                onFavoritePressed: () =>
                    _controller.toggleFavorite(asset.symbol),
              ),
          ],
        ),
      if (lastUpdate != null) ...[
        const SizedBox(height: 16),
        LastUpdateLabel(
          lastUpdate: lastUpdate,
          isStale: isStale(lastUpdate, DateTime.now()),
        ),
      ],
    ];
  }
}

/// White search field, radius 16, height 50.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.divider),
    );

    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Nom ou symbole, ex. Apple, SPY',
          hintStyle: const TextStyle(color: AppColors.muted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
          // Rebuilds only the clear button when the text changes.
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Effacer la recherche',
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.muted,
                    onPressed: onClear,
                  ),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
