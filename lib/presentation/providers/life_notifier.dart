import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/domain/entities/activity.dart';
import 'package:jalan_hidup_wni/domain/entities/character.dart';
import 'package:jalan_hidup_wni/domain/entities/game_models.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';
import 'package:jalan_hidup_wni/domain/entities/history_article.dart';
import 'package:jalan_hidup_wni/game_engine/history_article_builder.dart';
import 'package:jalan_hidup_wni/game_engine/history_context.dart';
import 'package:jalan_hidup_wni/presentation/providers/app_providers.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';

class LifeState {
  const LifeState({
    this.save,
    this.pendingEvent,
    this.pendingHistoryArticle,
    this.pendingHistoryFallbackImage,
    this.openingStory,
    this.isLoading = false,
    this.error,
  });

  final LifeSave? save;
  final GameEvent? pendingEvent;
  final HistoryArticle? pendingHistoryArticle;
  final String? pendingHistoryFallbackImage;
  final String? openingStory;
  final bool isLoading;
  final String? error;

  LifeState copyWith({
    LifeSave? save,
    GameEvent? pendingEvent,
    HistoryArticle? pendingHistoryArticle,
    String? pendingHistoryFallbackImage,
    String? openingStory,
    bool? isLoading,
    String? error,
    bool clearEvent = false,
    bool clearHistory = false,
  }) =>
      LifeState(
        save: save ?? this.save,
        pendingEvent: clearEvent ? null : (pendingEvent ?? this.pendingEvent),
        pendingHistoryArticle: clearHistory
            ? null
            : (pendingHistoryArticle ?? this.pendingHistoryArticle),
        pendingHistoryFallbackImage: clearHistory
            ? null
            : (pendingHistoryFallbackImage ??
                this.pendingHistoryFallbackImage),
        openingStory: openingStory ?? this.openingStory,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class LifeNotifier extends StateNotifier<LifeState> {
  LifeNotifier(this._ref) : super(const LifeState());

  final Ref _ref;
  final _history = HistoryContext();

  Future<void> loadExisting() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final save = await _ref.read(lifeRepositoryProvider).loadSave();
      state = LifeState(save: save, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> startNewLife(Character character) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final simulator = _ref.read(lifeSimulatorProvider);
      final presidents = await _ref.read(presidentsProvider.future);
      final eras = await _ref.read(erasProvider.future);

      final president =
          _history.presidentAtYear(character.birthYear, presidents);
      final era = _history.eraAtYear(character.birthYear, eras);
      final opening = _history.buildOpeningStory(
        birthYear: character.birthYear,
        province: character.province,
        name: character.name,
        president: president,
        era: era,
      );

      final save = simulator.createNewLife(character);
      await _ref.read(lifeRepositoryProvider).saveLife(save);
      state = LifeState(
        save: save,
        openingStory: opening,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> performActivity(ActivityDefinition activity) async {
    final current = state.save;
    if (current == null || !current.isAlive) return;

    state = state.copyWith(isLoading: true);
    try {
      final engine = _ref.read(activityEngineProvider);
      final result = await engine.perform(save: current, activity: activity);

      if (result.message != null) {
        state = state.copyWith(isLoading: false, error: result.message);
        return;
      }

      await _ref.read(lifeRepositoryProvider).saveLife(result.save);
      await _ref.read(audioServiceProvider).tap();

      state = LifeState(
        save: result.save,
        pendingEvent: result.surpriseEvent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> ageUp() async {
    final current = state.save;
    if (current == null || !current.isAlive) return;

    state = state.copyWith(isLoading: true);
    try {
      final simulator = _ref.read(lifeSimulatorProvider);
      final presidents = await _ref.read(presidentsProvider.future);
      final eras = await _ref.read(erasProvider.future);
      final events = await _ref.read(nationalEventsProvider.future);

      final result = await simulator.ageUp(
        save: current,
        presidents: presidents,
        eras: eras,
        nationalEvents: events,
      );

      HistoryArticle? historyArticle;
      String? fallbackImage;
      if (result.nationalEvent != null) {
        final scraped = await _ref
            .read(contentSourceProvider)
            .getArticleById(result.nationalEvent!.effectiveArticleId);
        historyArticle = articleFromNationalEvent(
          result.nationalEvent!,
          scraped: scraped,
        );
        fallbackImage = result.nationalEvent!.fallbackImage;
      }

      await _ref.read(lifeRepositoryProvider).saveLife(result.save);
      state = LifeState(
        save: result.save,
        pendingEvent: result.randomEvent,
        pendingHistoryArticle: historyArticle,
        pendingHistoryFallbackImage: fallbackImage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resolveEvent(GameEventChoice choice) async {
    final current = state.save;
    final event = state.pendingEvent;
    if (current == null || event == null) return;

    final simulator = _ref.read(lifeSimulatorProvider);
    final updated = simulator.applyEventChoice(current, choice);
    await _ref.read(lifeRepositoryProvider).saveLife(updated);

    final audio = _ref.read(audioServiceProvider);
    final netPositive = choice.effects.values.fold<int>(0, (a, b) => a + b);
    if (netPositive >= 0) {
      await audio.positive();
    } else {
      await audio.negative();
    }

    state = state.copyWith(save: updated, clearEvent: true);
  }

  void dismissHistoryArticle() {
    state = state.copyWith(clearHistory: true);
  }

  void dismissEvent() {
    state = state.copyWith(clearEvent: true);
  }

  Future<void> clearSave() async {
    await _ref.read(lifeRepositoryProvider).clearSave();
    state = const LifeState();
  }
}

final lifeNotifierProvider =
    StateNotifierProvider<LifeNotifier, LifeState>((ref) {
  return LifeNotifier(ref);
});
