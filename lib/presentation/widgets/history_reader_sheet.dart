import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/domain/entities/history_article.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryReaderSheet extends StatelessWidget {
  const HistoryReaderSheet({
    super.key,
    required this.article,
    this.fallbackImage,
    this.onContinue,
  });

  final HistoryArticle article;
  final String? fallbackImage;
  final VoidCallback? onContinue;

  static Future<void> show(
    BuildContext context, {
    required HistoryArticle article,
    String? fallbackImage,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HistoryReaderSheet(
        article: article,
        fallbackImage: fallbackImage,
        onContinue: () => Navigator.pop(ctx),
      ),
    );
  }

  String? get _imagePath => article.imageAsset ?? fallbackImage;

  Color _categoryColor(String category) => switch (category) {
        'kemerdekaan' => AppColors.gold,
        'politik' => AppColors.red,
        'ekonomi' => AppColors.primary,
        'bencana' => AppColors.red,
        'militer' => const Color(0xFF5D4037),
        'teknologi' => AppColors.blue,
        'pendidikan' => AppColors.primary,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final accent = _categoryColor(article.category);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  children: [
                    _HeroImage(path: _imagePath, accent: accent),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _Badge(
                          label: '${article.year}',
                          color: accent,
                        ),
                        const SizedBox(width: 8),
                        _Badge(
                          label: article.category.toUpperCase(),
                          color: accent.withValues(alpha: 0.7),
                          outline: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ContextBox(text: article.context, accent: accent),
                    const SizedBox(height: 14),
                    Text(
                      article.summary,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.body,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (article.wikiUrl != null) ...[
                      OutlinedButton.icon(
                        onPressed: () => _openWiki(article.wikiUrl!),
                        icon: const Icon(Icons.menu_book_outlined, size: 18),
                        label: const Text('Baca lengkap di Wikipedia'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: accent.withValues(alpha: 0.5)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sumber: ${article.source}. ${article.license}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                    SizedBox(height: 80 + bottom),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinue ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Lanjutkan hidup'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openWiki(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.path, required this.accent});

  final String? path;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: path != null
            ? Image.asset(
                path!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(accent),
              )
            : _placeholder(accent),
      ),
    );
  }

  Widget _placeholder(Color accent) {
    return Container(
      color: accent.withValues(alpha: 0.15),
      child: Icon(Icons.landscape_outlined, size: 64, color: accent),
    );
  }
}

class _ContextBox extends StatelessWidget {
  const _ContextBox({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                'Keadaan Indonesia saat itu',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.outline = false,
  });

  final String label;
  final Color color;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
