import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';
import 'package:jalan_hidup_wni/presentation/providers/life_notifier.dart';

class DeathScreen extends ConsumerStatefulWidget {
  const DeathScreen({super.key});

  @override
  ConsumerState<DeathScreen> createState() => _DeathScreenState();
}

class _DeathScreenState extends ConsumerState<DeathScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: AppMotion.dramatic)
      ..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playLegacyBgm();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
        parent: _intro,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  @override
  Widget build(BuildContext context) {
    final save = ref.watch(lifeNotifierProvider).save;

    if (save == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Kembali'),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AssetPaths.event('near_death'),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.primaryDark),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  FadeTransition(
                    opacity: _interval(0, 0.4),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1)
                          .animate(_interval(0, 0.45)),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: AppColors.gold,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _interval(0.2, 0.6),
                    child: Column(
                      children: [
                        Text(
                          save.character.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${save.character.birthYear} — ${save.currentYear}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Meninggal usia ${save.age} tahun',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _interval(0.4, 0.85),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(_interval(0.4, 0.85)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: AppColors.softShadow(),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Legacy Score',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: save.legacyScore),
                              duration: AppMotion.dramatic,
                              curve: AppMotion.easeOut,
                              builder: (_, v, __) => Text(
                                '$v',
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const Divider(height: 28),
                            _legacyRow('Kekayaan', 'Rp ${save.wealth}'),
                            _legacyRow('Kebahagiaan', '${save.happiness}'),
                            _legacyRow('Reputasi', '${save.reputation}'),
                            _legacyRow('Fase terakhir', save.phaseId),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _interval(0.7, 1),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [AppColors.gold, AppColors.goldDeep],
                              ),
                              boxShadow: AppColors.glowShadow(AppColors.gold),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                await ref
                                    .read(lifeNotifierProvider.notifier)
                                    .clearSave();
                                if (context.mounted) context.go('/home');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: AppColors.textDark,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text('Hidup Baru'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text(
                            'Menu Utama',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legacyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
