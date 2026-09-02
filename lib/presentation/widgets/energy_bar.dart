import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';

class EnergyBar extends StatelessWidget {
  const EnergyBar({
    super.key,
    required this.energy,
    required this.maxEnergy,
  });

  final int energy;
  final int maxEnergy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.bolt, color: AppColors.gold, size: 20),
        const SizedBox(width: 6),
        Text(
          'Energi tahun ini',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(maxEnergy, (i) {
          final filled = i < energy;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              Icons.bolt,
              size: 22,
              color: filled ? AppColors.gold : AppColors.surface,
            ),
          );
        }),
        const Spacer(),
        Text(
          '$energy/$maxEnergy',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
