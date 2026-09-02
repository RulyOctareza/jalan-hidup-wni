import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';
import 'package:jalan_hidup_wni/presentation/providers/life_notifier.dart';

class DeathScreen extends ConsumerStatefulWidget {
  const DeathScreen({super.key});

  @override
  ConsumerState<DeathScreen> createState() => _DeathScreenState();
}

class _DeathScreenState extends ConsumerState<DeathScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playLegacyBgm();
    });
  }

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
            errorBuilder: (_, __, ___) => Container(color: AppColors.primaryDark),
          ),
          Container(color: Colors.black.withValues(alpha: 0.6)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  const Icon(Icons.flag, color: AppColors.gold, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    save.character.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Legacy Score',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '${save.legacyScore}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Divider(),
                          _legacyRow('Kekayaan', 'Rp ${save.wealth}'),
                          _legacyRow('Kebahagiaan', '${save.happiness}'),
                          _legacyRow('Reputasi', '${save.reputation}'),
                          _legacyRow('Fase terakhir', save.phaseId),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(lifeNotifierProvider.notifier)
                            .clearSave();
                        if (context.mounted) context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textDark,
                      ),
                      child: const Text('Hidup Baru'),
                    ),
                  ),
                  const SizedBox(height: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _legacyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
