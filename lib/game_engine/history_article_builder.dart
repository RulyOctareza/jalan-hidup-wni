import 'package:jalan_hidup_wni/domain/entities/game_models.dart';
import 'package:jalan_hidup_wni/domain/entities/history_article.dart';

/// Builds a readable history article from game content when Wikipedia
/// scrape is unavailable.
HistoryArticle articleFromNationalEvent(
  NationalEventInfo event, {
  HistoryArticle? scraped,
}) {
  if (scraped != null && scraped.hasRichContent) {
    return scraped;
  }

  final era = _eraLabel(event.year);
  return HistoryArticle(
    id: event.effectiveArticleId,
    year: event.year,
    title: event.title,
    category: _categoryLabel(event.id),
    context:
        'Tahun ${event.year}. $era. Peristiwa ini mempengaruhi kehidupan '
        'sehari-hari jutaan WNI — termasuk karaktermu.',
    summary: event.description,
    body: _buildBody(event),
    imageAsset: scraped?.imageAsset ?? event.fallbackImage,
    wikiUrl: scraped?.wikiUrl,
    source: scraped?.source ?? 'Jalan Hidup WNI',
    license: scraped?.license ?? 'Konten edukatif',
  );
}

String _eraLabel(int year) {
  if (year < 1950) return 'Indonesia baru merdeka';
  if (year < 1967) return 'Era Orde Lama di bawah Soekarno';
  if (year < 1980) return 'Awal Orde Baru di bawah Soeharto';
  if (year < 1998) return 'Orde Baru — stabilitas sekaligus tekanan politik';
  if (year < 2004) {
    return 'Reformasi — transisi menuju demokrasi';
  }
  if (year < 2014) return 'Era demokrasi stabil pasca-Reformasi';
  if (year < 2024) return 'Era digital, startup, dan infrastruktur masif';
  return 'Indonesia menuju masa depan';
}

String _categoryLabel(String eventId) {
  if (eventId.contains('krismon') || eventId.contains('bbm')) {
    return 'ekonomi';
  }
  if (eventId.contains('covid') || eventId.contains('tsunami')) {
    return 'bencana';
  }
  if (eventId.contains('facebook') || eventId.contains('ai')) {
    return 'teknologi';
  }
  if (eventId.contains('utbk') || eventId.contains('belajar')) {
    return 'pendidikan';
  }
  return 'politik';
}

String _buildBody(NationalEventInfo event) {
  final buffer = StringBuffer()
    ..writeln(event.description)
    ..writeln()
    ..writeln(
      'Sebagai WNI yang hidup di tahun ${event.year}, kamu merasakan '
      'dampak peristiwa ini lewat berita, harga barang, sekolah, pekerjaan, '
      'atau suasana di lingkungan sekitar. Peristiwa nasional seperti '
      '${event.title} sering mengubah rencana hidup orang biasa — '
      'bukan hanya para pemimpin di ibu kota.',
    );
  return buffer.toString().trim();
}
