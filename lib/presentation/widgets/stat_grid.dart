import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';

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
                colors: [const Color(0xFFFFB300), const Color(0xFFFF8F00)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Sehat',
                value: health,
                icon: AssetPaths.stat('health'),
                colors: [const Color(0xFFEF5350), const Color(0xFFC62828)],
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
                colors: [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Tampan',
                value: looks,
                icon: AssetPaths.stat('looks'),
                colors: [const Color(0xFFEC407A), const Color(0xFFC2185B)],
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
  });

  final String label;
  final int value;
  final String icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value / 100),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.first.withValues(alpha: 0.15),
                colors.last.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.first.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(icon, width: 24, height: 24),
                  const Spacer(),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: value),
                    duration: const Duration(milliseconds: 600),
                    builder: (_, v, __) => Text(
                      '$v',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colors.last,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: animValue,
                  minHeight: 7,
                  backgroundColor: AppColors.surface,
                  color: colors.first,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WealthCard extends StatelessWidget {
  const _WealthCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.2),
            AppColors.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Image.asset(AssetPaths.stat('wealth'), width: 28, height: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kekayaan',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
