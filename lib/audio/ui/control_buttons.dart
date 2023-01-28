import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../audio_controller.dart';
import '../audio_state_notifier.dart';

class ControlButtons extends ConsumerWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sideButtonWidth = 60.0;
    final controller = ref.read(audioControllerProvider);
    final playbackState = ref.watch(playbackStateProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: sideButtonWidth,
          child: FittedBox(
            child: TextButton(
              onPressed: () => {},
              child: const Text(
                'TODO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            (Icons.fast_rewind),
            size: 32,
          ),
        ),
        IconButton(
          onPressed: () {
            if (playbackState.playing) {
              controller.pause();
            } else {
              controller.play();
            }
          },
          iconSize: 64,
          icon: Icon(
            playbackState.playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            size: 64,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            (Icons.fast_forward),
            size: 32,
          ),
        ),
        SizedBox(
          width: sideButtonWidth,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              (Icons.settings),
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}
