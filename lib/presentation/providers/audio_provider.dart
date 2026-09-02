import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/core/audio/audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
