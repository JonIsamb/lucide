import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/simulator_controller.dart';
import 'presentation/simulator_state.dart';
import 'presentation/widgets/result_view.dart';
import 'presentation/widgets/saved_list.dart';
import 'presentation/widgets/simulation_form.dart';

/// The Simulations tab: "ce que j'aurais vraiment gagné". It only shows
/// [SimulatorState] and forwards the user's actions to the controller.
class SimulatorScreen extends ConsumerWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(simulatorControllerProvider);
    final controller = ref.read(simulatorControllerProvider.notifier);
    final state = async.value;

    if (state == null) {
      return SafeArea(
        child: async.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Les données de la simulation sont illisibles.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(simulatorControllerProvider),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
      );
    }

    final result = state.result;
    if (result != null) {
      return SafeArea(
        bottom: false,
        child: ResultView(
          // A new calculation gets a new view, so the animation restarts.
          key: ValueKey((result, state.animateResult)),
          result: result,
          animate: state.animateResult,
          isSaved: state.phase == SimulatorPhase.saved,
          onSave: controller.save,
          onBack: controller.backToForm,
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(
            'Simulations',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Ce que tu aurais vraiment gagné, après change, frais, impôt et '
            'inflation.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SimulationForm(
            state: state,
            onAsset: controller.selectAsset,
            onAmount: controller.setAmountText,
            onBuyDay: controller.setBuyDay,
            onSellDay: controller.setSellDay,
            onEnvelope: controller.setEnvelope,
            onBrokerageKind: controller.setBrokerageKind,
            onBrokerage: controller.setBrokerageText,
            onAnnualFee: controller.setAnnualFeeText,
            onCompute: controller.compute,
          ),
          SavedList(
            saved: state.saved,
            onOpen: controller.openSaved,
            onDelete: (item) => controller.deleteSaved(item.id),
          ),
        ],
      ),
    );
  }
}
