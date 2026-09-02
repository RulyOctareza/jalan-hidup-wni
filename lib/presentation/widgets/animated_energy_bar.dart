import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.18),
            AppColors.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Text(
            'Energi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 10),
          ...List.generate(maxEnergy, (i) {
            final filled = i < energy;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: filled ? 1.0 : 0.35),
                duration: Duration(milliseconds: 300 + i * 80),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 26,
                      color: filled ? AppColors.gold : AppColors.surface,
                      shadows: filled
                          ? [
                              Shadow(
                                color: AppColors.gold.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              ),
            );
          }),
          const Spacer(),
          Text(
            '$energy/$maxEnergy',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
