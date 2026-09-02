import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/domain/entities/game_models.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';
import 'package:jalan_hidup_wni/game_engine/history_article_builder.dart';
import 'package:jalan_hidup_wni/presentation/providers/app_providers.dart';
import 'package:jalan_hidup_wni/presentation/widgets/history_reader_sheet.dart';

class LifeLogPanel extends ConsumerWidget {
  const LifeLogPanel({super.key, required this.log});

  final List<LifeLogEntry> log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (log.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            const Text(
              'Riwayat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Spacer(),
            Text(
              '${log.length} entri',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Ketuk 📜 untuk baca sejarah lengkap',
          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: log.take(12).length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final entry = log[index];
              final accent = _accentFor(entry);
              return _LogChip(
                age: entry.age,
                message: entry.message,
                accent: accent,
                tappable: entry.isHistorical,
                onTap: entry.articleId == null
                    ? null
                    : () => _openArticle(context, ref, entry.articleId!),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _accentFor(LifeLogEntry entry) {
    if (entry.type == LifeLogType.history || entry.message.startsWith('📜')) {
      return AppColors.gold;
    }
    if (entry.type == LifeLogType.news || entry.message.startsWith('📰')) {
      return AppColors.blue;
    }
    if (entry.message.startsWith('🔴') || entry.message.startsWith('⚡')) {
      return AppColors.red;
    }
    return AppColors.primary;
  }

  Future<void> _openArticle(
    BuildContext context,
    WidgetRef ref,
    String articleId,
  ) async {
    final content = ref.read(contentSourceProvider);
    final events = await ref.read(nationalEventsProvider.future);
    final scraped = await content.getArticleById(articleId);
    NationalEventInfo? event;
    for (final e in events) {
      if (e.id == articleId || e.effectiveArticleId == articleId) {
        event = e;
        break;
      }
    }

    if (!context.mounted) return;

    if (event != null) {
      final article = articleFromNationalEvent(event, scraped: scraped);
      await HistoryReaderSheet.show(
        context,
        article: article,
        fallbackImage: event.fallbackImage,
      );
      return;
    }

    if (scraped != null) {
      await HistoryReaderSheet.show(context, article: scraped);
    }
  }
}

class _LogChip extends StatelessWidget {
  const _LogChip({
    required this.age,
    required this.message,
    required this.accent,
    this.tappable = false,
    this.onTap,
  });

  final int age;
  final String message;
  final Color accent;
  final bool tappable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: tappable ? 0.45 : 0.25),
          width: tappable ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Usia $age',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
              if (tappable) ...[
                const Spacer(),
                Icon(Icons.menu_book_outlined, size: 14, color: accent),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              message,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, height: 1.3),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: chip,
      ),
    );
  }
}
