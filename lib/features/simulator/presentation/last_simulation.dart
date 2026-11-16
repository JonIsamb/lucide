import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/simulator_repository.dart';
import '../domain/saved_simulation.dart';

/// The most recently saved simulation, for the home screen. Null data: no
/// simulation saved yet.
///
/// It reads the database only: unlike `simulatorControllerProvider`, it
/// never seeds the rates nor calls the network, so the home screen stays
/// light at startup.
final lastSimulationProvider = StreamProvider<SavedSimulation?>(
  (ref) => ref
      .watch(simulatorRepositoryProvider)
      .watchSaved()
      .map((saved) => saved.firstOrNull),
  // No automatic retry: a local read either works or the app is broken.
  retry: (_, _) => null,
);
