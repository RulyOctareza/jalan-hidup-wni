import 'package:jalan_hidup_wni/domain/entities/game_models.dart';

class HistoryContext {
  PresidentInfo? presidentAtYear(int year, List<PresidentInfo> presidents) {
    for (final p in presidents) {
      if (year >= p.startYear && year <= p.endYear) return p;
    }
    return presidents.isNotEmpty ? presidents.last : null;
  }

  EraInfo? eraAtYear(int year, List<EraInfo> eras) {
    for (final e in eras) {
      if (year >= e.startYear && year <= e.endYear) return e;
    }
    return eras.isNotEmpty ? eras.last : null;
  }

  NationalEventInfo? eventAtYear(
    int year,
    List<NationalEventInfo> events,
  ) {
    for (final e in events) {
      if (e.year == year) return e;
    }
    return null;
  }

  String buildOpeningStory({
    required int birthYear,
    required String province,
    required String name,
    required PresidentInfo? president,
    required EraInfo? era,
  }) {
    final presName = president?.name ?? 'Presiden';
    final eraDesc = era?.description ?? 'Indonesia berkembang';
    return 'Tahun $birthYear. $eraDesc\n\n'
        'Presiden saat $name lahir: $presName.\n'
        'Keluargamu di $province menanti perjalanan hidup yang panjang.';
  }

  String buildNewsHeadline({
    required int year,
    required int age,
    required PresidentInfo? president,
    NationalEventInfo? nationalEvent,
  }) {
    final pres = president?.name ?? '-';
    if (nationalEvent != null) {
      return '📰 $year — Usia $age | Presiden: $pres\n'
          '${nationalEvent.headline}';
    }
    return '📰 $year — Usia $age | Presiden: $pres\n'
        'Indonesia melangkah ke tahun $year.';
  }
}
