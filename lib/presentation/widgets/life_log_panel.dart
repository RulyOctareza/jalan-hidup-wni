import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/core/theme/app_motion.dart';
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

    final visible = log.take(12).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Riwayat',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
        const SizedBox(height: 10),
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final entry = visible[index];
              final accent = _accentFor(entry);
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 320 + index * 45),
                curve: AppMotion.easeOut,
                builder: (context, t, child) {
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset((1 - t) * 18, 0),
                      child: child,
                    ),
                  );
                },
                child: _LogChip(
                  age: entry.age,
                  message: entry.message,
                  accent: accent,
                  tappable: entry.isHistorical,
                  onTap: entry.articleId == null
                      ? null
                      : () => _openArticle(context, ref, entry.articleId!),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _accentFor(LifeLogEntry entry) {
    if (entry.type == LifeLogType.history || entry.message.startsWith('📜')) {
      return AppColors.goldDeep;
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

class _LogChip extends StatefulWidget {
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
  State<_LogChip> createState() => _LogChipState();
}

class _LogChipState extends State<_LogChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final chip = AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: AppMotion.instant,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        width: 224,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.accent.withValues(alpha: widget.tappable ? 0.5 : 0.22),
            width: widget.tappable ? 1.5 : 1,
          ),
          boxShadow: AppColors.softShadow(color: widget.accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Usia ${widget.age}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: widget.accent,
                    ),
                  ),
                ),
                if (widget.tappable) ...[
                  const Spacer(),
                  Icon(
                    Icons.menu_book_rounded,
                    size: 15,
                    color: widget.accent,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                widget.message,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.onTap == null) return chip;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: chip,
    );
  }
}
