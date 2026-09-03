import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';

class AnimatedEnergyBar extends StatelessWidget {
  const AnimatedEnergyBar({
    super.key,
    required this.energy,
    required this.maxEnergy,
  });

  final int energy;
  final int maxEnergy;

  @override
  Widget build(BuildContext context) {
    final empty = energy <= 0;

    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: empty
              ? [
                  AppColors.red.withValues(alpha: 0.12),
                  AppColors.red.withValues(alpha: 0.04),
                ]
              : [
                  AppColors.gold.withValues(alpha: 0.22),
                  AppColors.gold.withValues(alpha: 0.06),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (empty ? AppColors.red : AppColors.gold)
              .withValues(alpha: 0.35),
        ),
        boxShadow: AppColors.softShadow(
          color: empty ? AppColors.red : AppColors.goldDeep,
        ),
      ),
      child: Row(
        children: [
          Text(
            'Energi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: empty ? AppColors.red : AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          ...List.generate(maxEnergy, (i) {
            final filled = i < energy;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TweenAnimationBuilder<double>(
                key: ValueKey('bolt_${i}_$filled'),
                tween: Tween(begin: 0.55, end: filled ? 1.0 : 0.38),
                duration: Duration(milliseconds: 320 + i * 90),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Icon(
                  Icons.bolt_rounded,
                  size: 28,
                  color: filled
                      ? AppColors.gold
                      : AppColors.surface.withValues(alpha: 0.9),
                  shadows: filled
                      ? [
                          Shadow(
                            color: AppColors.gold.withValues(alpha: 0.7),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
          const Spacer(),
          AnimatedDefaultTextStyle(
            duration: AppMotion.fast,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: empty ? AppColors.red : AppColors.textDark,
            ),
            child: Text('$energy/$maxEnergy'),
          ),
        ],
      ),
    );
  }
}
