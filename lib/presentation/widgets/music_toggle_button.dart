import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';

class MusicToggleButton extends ConsumerWidget {
  const MusicToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(musicEnabledProvider);
    return IconButton(
      tooltip: enabled ? 'Matikan musik' : 'Nyalakan musik',
      onPressed: () {
        final next = !ref.read(musicEnabledProvider);
        ref.read(musicEnabledProvider.notifier).state = next;
        ref.read(audioServiceProvider).enabled = next;
        if (next) {
          ref.read(audioServiceProvider).playMenuBgm();
        }
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Icon(
          enabled ? Icons.music_note : Icons.music_off,
          key: ValueKey(enabled),
          color: Colors.white,
        ),
      ),
    );
  }
}
