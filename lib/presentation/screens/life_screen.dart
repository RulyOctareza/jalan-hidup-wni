import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/presentation/providers/app_providers.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';
import 'package:jalan_hidup_wni/presentation/providers/life_notifier.dart';
import 'package:jalan_hidup_wni/presentation/widgets/activity_menu_sheet.dart';
import 'package:jalan_hidup_wni/presentation/widgets/energy_bar.dart';
import 'package:jalan_hidup_wni/presentation/widgets/event_dialog.dart';
import 'package:jalan_hidup_wni/presentation/widgets/phase_badge.dart';
import 'package:jalan_hidup_wni/presentation/widgets/stat_bar.dart';

class LifeScreen extends ConsumerStatefulWidget {
  const LifeScreen({super.key});

  @override
  ConsumerState<LifeScreen> createState() => _LifeScreenState();
}

class _LifeScreenState extends ConsumerState<LifeScreen> {
  @override
  void initState() {
    super.initState();
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

  void _showSurpriseBanner(String title) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Kejadian: $title'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatRupiah(int amount) {
    if (amount >= 1_000_000_000) {
      return 'Rp ${(amount / 1_000_000_000).toStringAsFixed(1)}M';
    }
    if (amount >= 1_000_000) {
      return 'Rp ${(amount / 1_000_000).toStringAsFixed(1)}jt';
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
      if (next.pendingEvent != null &&
          prev?.pendingEvent?.id != next.pendingEvent?.id) {
        _showSurpriseBanner(next.pendingEvent!.title);
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tidak ada save ditemukan'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final simulator = ref.read(lifeSimulatorProvider);
    final avatarKey = simulator.avatarKeyFor(save);
    final phaseName = phasesAsync.maybeWhen(
      data: (phases) {
        final match =
            phases.where((p) => p.id == save.phaseId).toList();
        return match.isEmpty ? save.phaseId : match.first.name;
      },
      orElse: () => save.phaseId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(save.character.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Column(
        children: [
          Image.asset(
            AssetPaths.background('home_urban'),
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 100,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        AssetPaths.avatar(avatarKey),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => CircleAvatar(
                          radius: 36,
                          child: Text('${save.age}'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${save.age} tahun • ${save.currentYear}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            save.character.province,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                          if (save.jobTitle != null)
                            Text(
                              save.jobTitle!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 6),
                          PhaseBadge(
                            phaseId: save.phaseId,
                            phaseName: phaseName,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        EnergyBar(
                          energy: save.energy,
                          maxEnergy: save.maxEnergy,
                        ),
                        if (!save.hasEnergyLeft) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Energi habis — waktunya menua?',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const Divider(height: 20),
                        StatBar(
                          label: 'Kebahagiaan',
                          value: save.happiness,
                          iconAsset: AssetPaths.stat('happiness'),
                          color: AppColors.gold,
                        ),
                        StatBar(
                          label: 'Kesehatan',
                          value: save.health,
                          iconAsset: AssetPaths.stat('health'),
                          color: AppColors.red,
                        ),
                        StatBar(
                          label: 'Kecerdasan',
                          value: save.smarts,
                          iconAsset: AssetPaths.stat('smarts'),
                          color: AppColors.blue,
                        ),
                        StatBar(
                          label: 'Penampilan',
                          value: save.looks,
                          iconAsset: AssetPaths.stat('looks'),
                          color: Colors.pink,
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Image.asset(
                              AssetPaths.stat('wealth'),
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kekayaan: ${_formatRupiah(save.wealth)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Riwayat Hidup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...save.log.take(8).map(
                      (e) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${e.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          title: Text(
                            e.message,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: lifeState.isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                                await ref.read(audioServiceProvider).ageUp();
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
      floatingActionButton: null,
    );
  }
}
