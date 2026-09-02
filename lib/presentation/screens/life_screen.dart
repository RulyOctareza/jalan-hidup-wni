import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/presentation/providers/app_providers.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';
import 'package:jalan_hidup_wni/presentation/providers/life_notifier.dart';
import 'package:jalan_hidup_wni/presentation/widgets/activity_menu_sheet.dart';
import 'package:jalan_hidup_wni/presentation/widgets/animated_energy_bar.dart';
import 'package:jalan_hidup_wni/presentation/widgets/event_dialog.dart';
import 'package:jalan_hidup_wni/presentation/widgets/history_reader_sheet.dart';
import 'package:jalan_hidup_wni/presentation/widgets/life_hero_header.dart';
import 'package:jalan_hidup_wni/presentation/widgets/life_log_panel.dart';
import 'package:jalan_hidup_wni/presentation/widgets/music_toggle_button.dart';
import 'package:jalan_hidup_wni/presentation/widgets/stat_grid.dart';

class LifeScreen extends ConsumerStatefulWidget {
  const LifeScreen({super.key});

  @override
  ConsumerState<LifeScreen> createState() => _LifeScreenState();
}

class _LifeScreenState extends ConsumerState<LifeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _agePulse;

  @override
  void initState() {
    super.initState();
    _agePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(lifeNotifierProvider);
      if (state.save == null) {
        await ref.read(lifeNotifierProvider.notifier).loadExisting();
      }
      final save = ref.read(lifeNotifierProvider).save;
      if (save != null) {
        ref.read(audioServiceProvider).playBgmForPhase(save.phaseId);
      }
      _showOpeningIfNeeded();
    });
  }

  @override
  void dispose() {
    _agePulse.dispose();
    super.dispose();
  }

  void _showOpeningIfNeeded() {
    final opening = ref.read(lifeNotifierProvider).openingStory;
    if (opening != null && mounted) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Awal Perjalanan'),
          content: Text(opening),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mulai'),
            ),
          ],
        ),
      );
    }
  }

  void _showHistoryArticle(LifeState state) {
    final article = state.pendingHistoryArticle;
    if (article == null || !mounted) return;
    ref.read(audioServiceProvider).event();
    HistoryReaderSheet.show(
      context,
      article: article,
      fallbackImage: state.pendingHistoryFallbackImage,
    ).then((_) {
      ref.read(lifeNotifierProvider.notifier).dismissHistoryArticle();
      final pending = ref.read(lifeNotifierProvider).pendingEvent;
      if (pending != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚡ ${pending.title}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        _showPendingEvent();
      }
    });
  }

  void _showPendingEvent() {
    final event = ref.read(lifeNotifierProvider).pendingEvent;
    if (event == null || !mounted) return;
    ref.read(audioServiceProvider).event();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EventDialog(
        event: event,
        onChoice: (choice) {
          ref.read(lifeNotifierProvider.notifier).resolveEvent(choice);
        },
      ),
    );
  }

  String _formatRupiah(int amount) {
    if (amount >= 1_000_000_000) {
      return 'Rp ${(amount / 1_000_000_000).toStringAsFixed(1)} M';
    }
    if (amount >= 1_000_000) {
      return 'Rp ${(amount / 1_000_000).toStringAsFixed(1)} jt';
    }
    return 'Rp $amount';
  }

  @override
  Widget build(BuildContext context) {
    final lifeState = ref.watch(lifeNotifierProvider);
    final phasesAsync = ref.watch(phasesProvider);
    final save = lifeState.save;

    ref.listen<LifeState>(lifeNotifierProvider, (prev, next) {
      if (next.save != null &&
          prev?.save?.phaseId != next.save?.phaseId) {
        ref.read(audioServiceProvider).playBgmForPhase(next.save!.phaseId);
      }
      if (next.save != null && prev?.save?.age != next.save?.age) {
        _agePulse.forward(from: 0);
      }
      if (next.pendingHistoryArticle != null &&
          prev?.pendingHistoryArticle?.id !=
              next.pendingHistoryArticle?.id) {
        _showHistoryArticle(next);
      } else if (next.pendingEvent != null &&
          prev?.pendingEvent?.id != next.pendingEvent?.id &&
          next.pendingHistoryArticle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚡ ${next.pendingEvent!.title}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        _showPendingEvent();
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
      if (next.save != null && !next.save!.isAlive) {
        context.go('/death');
      }
    });

    if (lifeState.isLoading && save == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (save == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hidup')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Kembali'),
          ),
        ),
      );
    }

    final simulator = ref.read(lifeSimulatorProvider);
    final avatarKey = simulator.avatarKeyFor(save);
    final phaseName = phasesAsync.maybeWhen(
      data: (phases) {
        final match = phases.where((p) => p.id == save.phaseId).toList();
        return match.isEmpty ? save.phaseId : match.first.name;
      },
      orElse: () => save.phaseId,
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(save.character.name),
        actions: const [
          MusicToggleButton(),
          SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          LifeHeroHeader(
            save: save,
            avatarKey: avatarKey,
            phaseName: phaseName,
            avatarBuilder: (key) => ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset(
                AssetPaths.avatar(key),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 32,
                  child: Text('${save.age}'),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedEnergyBar(
                    energy: save.energy,
                    maxEnergy: save.maxEnergy,
                  ),
                  if (!save.hasEnergyLeft) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Energi habis — waktunya menua?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withValues(alpha: 0.85),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  StatGrid(
                    happiness: save.happiness,
                    health: save.health,
                    smarts: save.smarts,
                    looks: save.looks,
                    wealthLabel: _formatRupiah(save.wealth),
                  ),
                  const SizedBox(height: 16),
                  LifeLogPanel(log: save.log),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: lifeState.isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ScaleTransition(
                  scale: _agePulse,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: save.isAlive
                              ? () => ActivityMenuSheet.show(context, save)
                              : null,
                          icon: const Icon(Icons.grid_view_rounded),
                          label: const Text('Aktivitas'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: save.isAlive
                              ? () async {
                                  await ref
                                      .read(audioServiceProvider)
                                      .ageUp();
                                  await ref
                                      .read(lifeNotifierProvider.notifier)
                                      .ageUp();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.textDark,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('+1 Th'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
