import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/presentation/providers/app_providers.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';
import 'package:jalan_hidup_wni/presentation/providers/life_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playMenuBgm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSaveAsync = ref.watch(hasSaveProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetPaths.brandSplash, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.7),
                  AppColors.primaryDark.withValues(alpha: 0.9),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      AssetPaths.brandIcon,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jalan Hidup WNI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hidup, berjuang, dan tulis sejarahmu',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(audioServiceProvider).tap();
                        context.push('/create');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textDark,
                      ),
                      child: const Text('Hidup Baru'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  hasSaveAsync.when(
                    data: (hasSave) => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: hasSave
                            ? () async {
                                await ref
                                    .read(lifeNotifierProvider.notifier)
                                    .loadExisting();
                                if (context.mounted) {
                                  final save =
                                      ref.read(lifeNotifierProvider).save;
                                  if (save != null && !save.isAlive) {
                                    context.go('/death');
                                  } else {
                                    context.go('/life');
                                  }
                                }
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          hasSave ? 'Lanjutkan Hidup' : 'Belum Ada Save',
                        ),
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
