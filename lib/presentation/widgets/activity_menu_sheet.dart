import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
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
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aktivitas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usia ${save.age} • Energi ${save.energy}/${save.maxEnergy}'
                      '${save.jobTitle != null ? ' • ${save.jobTitle}' : ''}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Event kejutan bisa muncul kapan saja setelah aktivitas.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: available.length,
                      itemBuilder: (context, index) {
                        final act = available[index];
                        final canAfford = act.energyCost == 0 ||
                            save.energy >= act.energyCost;
                        return _ActivityTile(
                          activity: act,
                          iconPath: _iconPath(act.icon),
                          enabled: canAfford,
                          onTap: () async {
                            Navigator.pop(context);
                            await ref
                                .read(lifeNotifierProvider.notifier)
                                .performActivity(act);
                          },
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

class _ActivityTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.white : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.star,
                  size: 36,
                  color: enabled ? AppColors.primary : Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                activity.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: enabled ? AppColors.textDark : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bolt,
                    size: 12,
                    color: enabled ? AppColors.gold : Colors.grey,
                  ),
                  Text(
                    activity.energyCost == 0
                        ? '+1'
                        : '-${activity.energyCost}',
                    style: TextStyle(
                      fontSize: 10,
                      color: enabled ? AppColors.textMuted : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
