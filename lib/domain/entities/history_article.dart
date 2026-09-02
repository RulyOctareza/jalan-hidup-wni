class HistoryArticle {
  const HistoryArticle({
    required this.id,
    required this.year,
    required this.title,
    required this.category,
    required this.context,
    required this.summary,
    required this.body,
    this.imageAsset,
    this.wikiUrl,
    this.source = 'Wikipedia Bahasa Indonesia',
    this.license = 'Wikipedia',
  });

  final String id;
  final int year;
  final String title;
  final String category;
  final String context;
  final String summary;
  final String body;
  final String? imageAsset;
  final String? wikiUrl;
  final String source;
  final String license;

  bool get hasRichContent =>
      body.length > 80 && !body.startsWith('Artikel sedang dimuat');

  factory HistoryArticle.fromJson(Map<String, dynamic> json) =>
      HistoryArticle(
        id: json['id'] as String,
        year: json['year'] as int,
        title: json['title'] as String,
        category: json['category'] as String,
        context: json['context'] as String,
        summary: json['summary'] as String,
        body: json['body'] as String,
        imageAsset: json['imageAsset'] as String?,
        wikiUrl: json['wikiUrl'] as String?,
        source: json['source'] as String? ?? 'Wikipedia Bahasa Indonesia',
        license: json['license'] as String? ?? 'Wikipedia',
      );
}
