import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../audio_controller.dart';
import '../audio_state_notifier.dart';

class AudioProgress extends ConsumerWidget {
  const AudioProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(audioControllerProvider);
    final progressState = ref.watch(progressStateProvider);
    return ProgressBar(
      onSeek: controller.seek,
      thumbRadius: 6,
      barHeight: 4,
      progress: Duration(seconds: progressState.current.inSeconds),
      total: Duration(seconds: progressState.total.inSeconds),
      timeLabelPadding: 4,
      timeLabelTextStyle: const TextStyle(
        color: Colors.black45,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}