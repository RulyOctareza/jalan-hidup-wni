import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';
import 'package:jalan_hidup_wni/presentation/providers/app_providers.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';
import 'package:jalan_hidup_wni/presentation/providers/life_notifier.dart';
import 'package:jalan_hidup_wni/presentation/widgets/music_toggle_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: AppMotion.slow)
      ..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playMenuBgm();
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
    final hasSaveAsync = ref.watch(hasSaveProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [MusicToggleButton(), SizedBox(width: 8)],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetPaths.brandSplash, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.62),
                  AppColors.primaryDark.withValues(alpha: 0.92),
                  const Color(0xFF0D3B12).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  FadeTransition(
                    opacity: _interval(0, 0.5),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.88, end: 1).animate(
                        _interval(0, 0.55),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: AppColors.glowShadow(AppColors.gold),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.asset(
                            AssetPaths.brandIcon,
                            width: 108,
                            height: 108,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeTransition(
                    opacity: _interval(0.25, 0.7),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(_interval(0.25, 0.7)),
                      child: const Column(
                        children: [
                          Text(
                            'Jalan Hidup WNI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Hidup, berjuang, dan tulis sejarahmu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _interval(0.5, 1),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(_interval(0.5, 1)),
                      child: Column(
                        children: [
                          _PrimaryHomeButton(
                            label: 'Hidup Baru',
                            onPressed: () {
                              ref.read(audioServiceProvider).tap();
                              context.push('/create');
                            },
                          ),
                          const SizedBox(height: 12),
                          hasSaveAsync.when(
                            data: (hasSave) => _SecondaryHomeButton(
                              label: hasSave
                                  ? 'Lanjutkan Hidup'
                                  : 'Belum Ada Save',
                              enabled: hasSave,
                              onPressed: () async {
                                await ref
                                    .read(lifeNotifierProvider.notifier)
                                    .loadExisting();
                                if (!context.mounted) return;
                                final save =
                                    ref.read(lifeNotifierProvider).save;
                                if (save != null && !save.isAlive) {
                                  context.go('/death');
                                } else {
                                  context.go('/life');
                                }
                              },
                            ),
                            loading: () => const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
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
}

class _PrimaryHomeButton extends StatelessWidget {
  const _PrimaryHomeButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.glowShadow(AppColors.gold),
          gradient: const LinearGradient(
            colors: [AppColors.gold, AppColors.goldDeep],
          ),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.textDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _SecondaryHomeButton extends StatelessWidget {
  const _SecondaryHomeButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white38,
          side: BorderSide(
            color: enabled ? Colors.white60 : Colors.white24,
            width: 1.4,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
