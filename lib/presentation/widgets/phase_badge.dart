import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';

class PhaseBadge extends StatelessWidget {
  const PhaseBadge({
    super.key,
    required this.phaseId,
    required this.phaseName,
  });

  final String phaseId;
  final String phaseName;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.normal,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey('$phaseId-$phaseName'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.phase(phaseId),
              width: 22,
              height: 22,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.flag_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              phaseName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
