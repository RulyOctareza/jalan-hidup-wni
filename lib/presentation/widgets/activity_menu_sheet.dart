import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';
import 'package:jalan_hidup_wni/domain/entities/activity.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';
import 'package:jalan_hidup_wni/presentation/providers/app_providers.dart';
import 'package:jalan_hidup_wni/presentation/providers/life_notifier.dart';

class ActivityMenuSheet extends ConsumerWidget {
  const ActivityMenuSheet({super.key, required this.save});

  final LifeSave save;

  static Future<void> show(BuildContext context, LifeSave save) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ActivityMenuSheet(save: save),
    );
  }

  String _iconPath(String icon) {
    return 'assets/images/icons/activities/activity_$icon.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pool = ref.watch(eventPoolProvider);
    final activitiesFuture = pool.getActivities();

    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.4,
      maxChildSize: 0.88,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aktivitas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Usia ${save.age} • Energi ${save.energy}/${save.maxEnergy}'
                      '${save.jobTitle != null ? ' • ${save.jobTitle}' : ''}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Event kejutan bisa muncul setelah aktivitas.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<ActivityDefinition>>(
                  future: activitiesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final available = pool.availableActivities(save);
                    if (available.isEmpty) {
                      return const Center(child: Text('Belum ada aktivitas'));
                    }
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: available.length,
                      itemBuilder: (context, index) {
                        final act = available[index];
                        final canAfford = act.energyCost == 0 ||
                            save.energy >= act.energyCost;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 280 + index * 40),
                          curve: AppMotion.easeOut,
                          builder: (context, t, child) {
                            return Opacity(
                              opacity: t,
                              child: Transform.scale(
                                scale: 0.92 + (0.08 * t),
                                child: child,
                              ),
                            );
                          },
                          child: _ActivityTile(
                            activity: act,
                            iconPath: _iconPath(act.icon),
                            enabled: canAfford,
                            onTap: () async {
                              Navigator.pop(context);
                              await ref
                                  .read(lifeNotifierProvider.notifier)
                                  .performActivity(act);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatefulWidget {
  const _ActivityTile({
    required this.activity,
    required this.iconPath,
    required this.enabled,
    required this.onTap,
  });

  final ActivityDefinition activity;
  final String iconPath;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: AppMotion.instant,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
            ),
            boxShadow: enabled
                ? AppColors.softShadow(color: AppColors.primary)
                : const [],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.iconPath,
                width: 42,
                height: 42,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.star_rounded,
                  size: 38,
                  color: enabled ? AppColors.primary : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.activity.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: enabled ? AppColors.textDark : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (enabled ? AppColors.gold : Colors.grey)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 12,
                      color: enabled ? AppColors.goldDeep : Colors.grey,
                    ),
                    Text(
                      widget.activity.energyCost == 0
                          ? '+1'
                          : '-${widget.activity.energyCost}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: enabled ? AppColors.textMuted : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
