import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';

class StatGrid extends StatelessWidget {
  const StatGrid({
    super.key,
    required this.happiness,
    required this.health,
    required this.smarts,
    required this.looks,
    required this.wealthLabel,
  });

  final int happiness;
  final int health;
  final int smarts;
  final int looks;
  final String wealthLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Bahagia',
                value: happiness,
                icon: AssetPaths.stat('happiness'),
                colors: const [Color(0xFFFFB300), Color(0xFFFF8F00)],
                delayMs: 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Sehat',
                value: health,
                icon: AssetPaths.stat('health'),
                colors: const [Color(0xFFEF5350), Color(0xFFC62828)],
                delayMs: 60,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Pintar',
                value: smarts,
                icon: AssetPaths.stat('smarts'),
                colors: const [Color(0xFF42A5F5), Color(0xFF1565C0)],
                delayMs: 120,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Tampan',
                value: looks,
                icon: AssetPaths.stat('looks'),
                colors: const [Color(0xFFEC407A), Color(0xFFC2185B)],
                delayMs: 180,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _WealthCard(label: wealthLabel),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
    required this.delayMs,
  });

  final String label;
  final int value;
  final String icon;
  final List<Color> colors;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + delayMs),
      curve: AppMotion.easeOut,
      builder: (context, entrance, child) {
        return Opacity(
          opacity: entrance.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - entrance) * 12),
            child: child,
          ),
        );
      },
      child: TweenAnimationBuilder<double>(
        key: ValueKey('$label-$value'),
        tween: Tween(begin: 0, end: value / 100),
        duration: AppMotion.slow,
        curve: AppMotion.easeOut,
        builder: (context, animValue, child) {
          return Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.first.withValues(alpha: 0.16),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.first.withValues(alpha: 0.22)),
              boxShadow: AppColors.softShadow(color: colors.last),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.first.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(icon, width: 22, height: 22),
                    ),
                    const Spacer(),
                    TweenAnimationBuilder<int>(
                      key: ValueKey(value),
                      tween: IntTween(begin: 0, end: value),
                      duration: AppMotion.slow,
                      builder: (_, v, __) => Text(
                        '$v',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: colors.last,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        color: AppColors.surface,
                      ),
                      FractionallySizedBox(
                        widthFactor: animValue.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colors),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: colors.first.withValues(alpha: 0.45),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WealthCard extends StatelessWidget {
  const _WealthCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: AppMotion.easeOut,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.28),
              AppColors.gold.withValues(alpha: 0.08),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
          boxShadow: AppColors.softShadow(color: AppColors.goldDeep),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                AssetPaths.stat('wealth'),
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kekayaan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: AppMotion.normal,
                    child: Text(
                      label,
                      key: ValueKey(label),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppColors.textDark,
                      ),
                    ),
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
