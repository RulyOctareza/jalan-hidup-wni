import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/core/audio/audio_service.dart';

final musicEnabledProvider = StateProvider<bool>((ref) => true);

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  final enabled = ref.watch(musicEnabledProvider);
  service.enabled = enabled;
  ref.onDispose(service.dispose);
  return service;
});
