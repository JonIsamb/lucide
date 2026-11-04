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
    required this.onBrokerageKind,
    required this.onBrokerage,
    required this.onAnnualFee,
    required this.onCompute,
  });

  final SimulatorState state;
  final ValueChanged<Instrument> onAsset;
  final ValueChanged<String> onAmount;
  final ValueChanged<DateTime> onBuyDay;
  final ValueChanged<DateTime> onSellDay;
  final ValueChanged<Envelope> onEnvelope;
  final ValueChanged<BrokerageKind> onBrokerageKind;
  final ValueChanged<String> onBrokerage;
  final ValueChanged<String> onAnnualFee;
  final VoidCallback onCompute;

  @override
  State<SimulationForm> createState() => _SimulationFormState();
}

class _SimulationFormState extends State<SimulationForm> {
  // Controllers hold the text being typed (visual state). They start from
  // the values kept by the Notifier, so coming back from a result keeps
  // the form filled.
  late final TextEditingController _amount;
  late final TextEditingController _brokerage;
  late final TextEditingController _annualFee;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _amount = TextEditingController(text: _text(s.amount));
    _brokerage = TextEditingController(
      text: _text(s.brokerageValue, zeroIsEmpty: true),
    );
    _annualFee = TextEditingController(
      text: _text(s.annualFeePercent, zeroIsEmpty: true),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _brokerage.dispose();
    _annualFee.dispose();
    super.dispose();
  }

  String _text(double? value, {bool zeroIsEmpty = false}) {
    if (value == null || (zeroIsEmpty && value == 0)) return '';
    return formatDecimal(
      value,
      decimals: value == value.roundToDouble() ? 0 : 2,
    ).replaceAll(' ', '').replaceAll(' ', '');
  }

  Future<void> _pickAsset() async {
    final picked = await showModalBottomSheet<Instrument>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AssetPicker(instruments: widget.state.instruments),
    );
    if (picked != null) widget.onAsset(picked);
  }

  Future<void> _pickDay(
    DateTime? current,
    ValueChanged<DateTime> onPicked,
  ) async {
    final range = widget.state.priceRange;
    if (range == null) return;
    final initial = current == null
        ? range.last
        : current.isBefore(range.first)
        ? range.first
        : current.isAfter(range.last)
        ? range.last
        : current;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: range.first,
      lastDate: range.last,
    );
    if (picked != null) {
      onPicked(DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

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
              _Label('Actif'),
              _Field(
                onTap: _pickAsset,
                icon: Icons.search_rounded,
                text: s.asset == null
                    ? 'Choisir un actif'
                    : '${s.asset!.name} (${s.asset!.shortCode})',
                placeholder: s.asset == null,
              ),
              if (noPrices) ...[
                const SizedBox(height: 6),
                Text(
                  'Aucun cours enregistré pour cet actif.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.fall,
                  ),
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
                  'prend la dernière clôture connue.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
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
              if (s.peaRefused) ...[
                const SizedBox(height: 8),
                Text(
                  'Ce PEA est impossible pour cet actif : il n’accepte que des '
                  'titres européens. Choisis le compte titres.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.fall,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _Label('Frais de courtage (achat et vente)'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _brokerage,
                      onChanged: widget.onBrokerage,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixText: s.brokerageKind == BrokerageKind.percent
                            ? '%'
                            : '€',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<BrokerageKind>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: BrokerageKind.percent,
                        label: Text('%'),
                      ),
                      ButtonSegment(
                        value: BrokerageKind.amount,
                        label: Text('€'),
                      ),
                    ],
                    selected: {s.brokerageKind},
                    onSelectionChanged: (v) => widget.onBrokerageKind(v.first),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Label('Frais annuels'),
              TextField(
                controller: _annualFee,
                onChanged: widget.onAnnualFee,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  suffixText: '% par an',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
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
