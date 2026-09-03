import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/scene/scene_resolver.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';
import 'package:jalan_hidup_wni/presentation/widgets/phase_badge.dart';

class LifeHeroHeader extends StatefulWidget {
  const LifeHeroHeader({
    super.key,
    required this.save,
    required this.avatarKey,
    required this.phaseName,
    required this.avatarBuilder,
  });

  final LifeSave save;
  final String avatarKey;
  final String phaseName;
  final Widget Function(String key) avatarBuilder;

  @override
  State<LifeHeroHeader> createState() => _LifeHeroHeaderState();
}

class _LifeHeroHeaderState extends State<LifeHeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kenBurns;

  @override
  void initState() {
    super.initState();
    _kenBurns = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _kenBurns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = SceneResolver.resolve(widget.save);
    final save = widget.save;

    return AnimatedSwitcher(
      duration: AppMotion.slow,
      switchInCurve: AppMotion.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.04, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey('${scene.backgroundAsset}_${save.currentYear}'),
        height: 214,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _kenBurns,
              builder: (context, child) {
                final scale = 1.0 + (_kenBurns.value * 0.06);
                return Transform.scale(scale: scale, child: child);
              },
              child: Image.asset(
                scene.backgroundAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.primary),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    ...scene.overlayGradient,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GlassChip(
                        child: Text(
                          '${save.currentYear} • ${scene.eraLabel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, AppColors.goldDeep],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.glowShadow(AppColors.gold),
                        ),
                        child: Text(
                          scene.sceneLabel,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Hero(
                        tag: 'avatar_${save.character.name}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.85),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: widget.avatarBuilder(widget.avatarKey),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration: AppMotion.normal,
                              child: Text(
                                '${save.age} tahun',
                                key: ValueKey(save.age),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            Text(
                              save.character.province,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                            if (save.jobTitle != null)
                              Text(
                                save.jobTitle!,
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      PhaseBadge(
                        phaseId: save.phaseId,
                        phaseName: widget.phaseName,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: child,
    );
  }
}
