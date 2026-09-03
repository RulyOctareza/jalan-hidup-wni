import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _agePulse;
  late AnimationController _contentIn;
  late Animation<double> _ageScale;

  @override
  void initState() {
    super.initState();
    _agePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _ageScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_agePulse);

    _contentIn = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    )..forward();

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
    _contentIn.dispose();
    super.dispose();
  }

  void _showOpeningIfNeeded() {
    final opening = ref.read(lifeNotifierProvider).openingStory;
    if (opening != null && mounted) {
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'opening',
        barrierColor: Colors.black54,
        transitionDuration: AppMotion.normal,
        pageBuilder: (ctx, _, __) => const SizedBox.shrink(),
        transitionBuilder: (ctx, anim, _, __) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(
                CurvedAnimation(parent: anim, curve: AppMotion.softBounce),
              ),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.auto_stories_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Awal Perjalanan'),
                  ],
                ),
                content: Text(opening, style: const TextStyle(height: 1.45)),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Mulai'),
                  ),
                ],
              ),
            ),
          );
        },
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
        title: Text(
          save.character.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
            avatarBuilder: (key) => ClipOval(
              child: Image.asset(
                AssetPaths.avatar(key),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    '${save.age}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _contentIn,
                curve: AppMotion.easeOut,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedEnergyBar(
                      energy: save.energy,
                      maxEnergy: save.maxEnergy,
                    ),
                    AnimatedSize(
                      duration: AppMotion.normal,
                      curve: AppMotion.easeOut,
                      child: !save.hasEnergyLeft
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Energi habis — waktunya menua?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    StatGrid(
                      happiness: save.happiness,
                      health: save.health,
                      smarts: save.smarts,
                      looks: save.looks,
                      wealthLabel: _formatRupiah(save.wealth),
                    ),
                    const SizedBox(height: 18),
                    LifeLogPanel(log: save.log),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: lifeState.isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: ScaleTransition(
                  scale: _ageScale,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _ActionButton(
                          onPressed: save.isAlive
                              ? () => ActivityMenuSheet.show(context, save)
                              : null,
                          icon: Icons.grid_view_rounded,
                          label: 'Aktivitas',
                          gradient: const [
                            AppColors.primarySoft,
                            AppColors.primary,
                          ],
                          foreground: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
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
                          label: '+1 Th',
                          gradient: const [
                            AppColors.gold,
                            AppColors.goldDeep,
                          ],
                          foreground: AppColors.textDark,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.gradient,
    required this.foreground,
    this.icon,
    this.onPressed,
  });

  final String label;
  final List<Color> gradient;
  final Color foreground;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: gradient),
          boxShadow: enabled
              ? AppColors.glowShadow(gradient.last)
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: foreground, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
