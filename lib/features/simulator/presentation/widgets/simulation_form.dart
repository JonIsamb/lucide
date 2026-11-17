import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../asset_detail/presentation/widgets/detail_card.dart';
import '../../../catalog/domain/instrument.dart';
import '../../domain/simulation_params.dart';
import '../simulator_state.dart';

/// The form of the Simulations tab. It shows [SimulatorState] and reports
/// every change to the callbacks; it validates nothing itself.
class SimulationForm extends StatefulWidget {
  const SimulationForm({
    super.key,
    required this.state,
    required this.onAsset,
    required this.onAmount,
    required this.onBuyDay,
    required this.onSellDay,
    required this.onEnvelope,
    required this.onCompute,
  });

  final SimulatorState state;
  final ValueChanged<Instrument> onAsset;
  final ValueChanged<String> onAmount;
  final ValueChanged<DateTime> onBuyDay;
  final ValueChanged<DateTime> onSellDay;
  final ValueChanged<Envelope> onEnvelope;
  final VoidCallback onCompute;

  @override
  State<SimulationForm> createState() => _SimulationFormState();
}

class _SimulationFormState extends State<SimulationForm> {
  // Controllers hold the text being typed (visual state). They start from
  // the values kept by the Notifier, so coming back from a result keeps
  // the form filled.
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _amount = TextEditingController(text: _text(s.amount));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  String _text(double? value) {
    if (value == null) return '';
    return formatDecimal(
      value,
      decimals: value == value.roundToDouble() ? 0 : 2,
    ).replaceAll(' ', '').replaceAll(' ', '');
  }

  Future<void> _pickAsset() async {
    final picked = await showModalBottomSheet<Instrument>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _AssetPicker(instruments: widget.state.selectableInstruments),
    );
    if (picked != null) widget.onAsset(picked);
  }

  Future<void> _pickDay(
    DateTime? current,
    ValueChanged<DateTime> onPicked,
  ) async {
    final range = widget.state.priceRange;
    final lastDay = widget.state.lastPickableDay;
    if (range == null || lastDay == null) return;
    final initial = current == null
        ? range.last
        : current.isBefore(range.first)
        ? range.first
        : current.isAfter(lastDay)
        ? lastDay
        : current;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: range.first,
      lastDate: lastDay,
    );
    if (picked != null) {
      onPicked(DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  /// The fixed fees, as a sentence for the envelope card.
  String _fees() =>
      'courtage ${formatDecimal(defaultBrokeragePercent, decimals: 1)} % '
      'à l’achat et à la vente, aucun frais annuel';

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final theme = Theme.of(context);
    final noPrices = s.asset != null && s.candles.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Où est détenu l’actif ?'),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<Envelope>(
                  showSelectedIcon: false,
                  segments: [
                    for (final e in Envelope.values)
                      ButtonSegment(value: e, label: Text(e.label)),
                  ],
                  selected: {s.envelope},
                  onSelectionChanged: (v) => widget.onEnvelope(v.first),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.envelope == Envelope.pea
                    ? 'Seuls les actifs éligibles au PEA sont proposés. '
                          'Frais standards : ${_fees()}.'
                    : 'Frais standards : ${_fees()}.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DetailCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Actif'),
              _Field(
                onTap: _pickAsset,
                icon: Icons.search_rounded,
                text: s.asset == null
                    ? 'Choisir un actif'
                    : '${s.asset!.name} (${s.asset!.shortCode})',
                placeholder: s.asset == null,
              ),
              if (s.pricesStatus == PricesStatus.downloading) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Téléchargement des cours…',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ] else if (noPrices) ...[
                const SizedBox(height: 6),
                Text(
                  'Les cours de cet actif ne sont pas enregistrés et n’ont '
                  'pas pu être téléchargés. Vérifie ta connexion.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.fall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => widget.onAsset(s.asset!),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Réessayer'),
                ),
              ],
              const SizedBox(height: 16),
              _Label('Montant investi'),
              TextField(
                controller: _amount,
                onChanged: widget.onAmount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: '1 000',
                  suffixText: '€',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Date d’achat'),
                        _Field(
                          onTap: s.priceRange == null
                              ? null
                              : () => _pickDay(s.buyDay, widget.onBuyDay),
                          icon: Icons.event_rounded,
                          text: s.buyDay == null ? '—' : formatDay(s.buyDay!),
                          placeholder: s.buyDay == null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Date de vente'),
                        _Field(
                          onTap: s.priceRange == null
                              ? null
                              : () => _pickDay(s.sellDay, widget.onSellDay),
                          icon: Icons.event_rounded,
                          text: s.sellDay == null ? '—' : formatDay(s.sellDay!),
                          placeholder: s.sellDay == null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (s.priceRange != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Cours disponibles du ${formatDay(s.priceRange!.first)} '
                  'au ${formatDay(s.priceRange!.last)}. Un jour sans cotation '
                  'prend la dernière clôture connue. Une date plus tardive '
                  'donne une prédiction.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (s.isPrediction) ...[
                const SizedBox(height: 6),
                Text(
                  'Prédiction purement spéculative : au delà du dernier cours '
                  'connu, le prix prolonge la croissance moyenne passée.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.fall,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: widget.onCompute,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Calculer ce que j’aurais vraiment gagné'),
        ),
        if (s.error != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.fallTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              s.error!.message,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.fall,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.muted,
      ),
    ),
  );
}

/// A tappable box that looks like a text field (asset and dates).
class _Field extends StatelessWidget {
  const _Field({
    required this.onTap,
    required this.icon,
    required this.text,
    required this.placeholder,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final String text;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(border: OutlineInputBorder()),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: placeholder ? AppColors.muted : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet listing the catalogue, with a search box.
class _AssetPicker extends StatefulWidget {
  const _AssetPicker({required this.instruments});

  final List<Instrument> instruments;

  @override
  State<_AssetPicker> createState() => _AssetPickerState();
}

class _AssetPickerState extends State<_AssetPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final matches = [
      for (final i in widget.instruments)
        if (query.isEmpty ||
            i.name.toLowerCase().contains(query) ||
            i.symbol.toLowerCase().contains(query))
          i,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un actif',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? const Center(child: Text('Aucun actif trouvé.'))
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final i = matches[index];
                        return ListTile(
                          title: Text(i.name),
                          subtitle: Text('${i.type.label} · ${i.shortCode}'),
                          onTap: () => Navigator.of(context).pop(i),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
