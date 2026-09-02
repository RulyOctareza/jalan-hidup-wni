import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/data/repositories/life_repository_impl.dart';
import 'package:jalan_hidup_wni/data/sources/content_source.dart';
import 'package:jalan_hidup_wni/data/sources/local/life_local_source.dart';
import 'package:jalan_hidup_wni/domain/entities/game_models.dart';
import 'package:jalan_hidup_wni/domain/repositories/life_repository.dart';
import 'package:jalan_hidup_wni/game_engine/activity_engine.dart';
import 'package:jalan_hidup_wni/game_engine/event_pool.dart';
import 'package:jalan_hidup_wni/game_engine/life_simulator.dart';

final contentSourceProvider = Provider<ContentSource>((ref) => ContentSource());

final eventPoolProvider = Provider<EventPool>((ref) => EventPool());

final activityEngineProvider = Provider<ActivityEngine>(
  (ref) => ActivityEngine(eventPool: ref.watch(eventPoolProvider)),
);

final lifeRepositoryProvider = Provider<LifeRepository>(
  (ref) => LifeRepositoryImpl(LifeLocalSource.instance),
);

final lifeSimulatorProvider = Provider<LifeSimulator>(
  (ref) => LifeSimulator(eventPool: ref.watch(eventPoolProvider)),
);

final presidentsProvider = FutureProvider<List<PresidentInfo>>((ref) async {
  return ref.watch(contentSourceProvider).getPresidents();
});

final erasProvider = FutureProvider<List<EraInfo>>((ref) async {
  return ref.watch(contentSourceProvider).getEras();
});

final nationalEventsProvider = FutureProvider<List<NationalEventInfo>>(
  (ref) async {
    return ref.watch(contentSourceProvider).getNationalEvents();
  },
);

final phasesProvider = FutureProvider<List<PhaseInfo>>((ref) async {
  return ref.watch(contentSourceProvider).getPhases();
});

final hasSaveProvider = FutureProvider<bool>((ref) async {
  return ref.watch(lifeRepositoryProvider).hasSave();
});
