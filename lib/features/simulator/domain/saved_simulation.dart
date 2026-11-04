import 'simulation_result.dart';

/// A simulation kept by the user, with the result computed at save time.
class SavedSimulation {
  const SavedSimulation({
    required this.id,
    required this.createdAt,
    required this.result,
  });

  final int id;
  final DateTime createdAt;
  final SimulationResult result;
}
