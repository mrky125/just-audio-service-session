import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../service_locator.dart';
import 'player/audio_player_handler.dart';
import 'audio_controller.dart';
import 'audio_state_notifier.dart';
import 'state/progress_bar_state.dart';

final audioListenerProvider = Provider((ref) => AudioListener(ref: ref));

class AudioListener {
  AudioListener({required this.ref});

  final Ref ref;
  final _handler = getIt<AudioPlayerHandler>();

  void startListen() {
    _listenPlaybackState();
    _listenDuration();
    _listenCurrentMediaItem();
    _listenProcessingState();
  }

  void _listenPlaybackState() {
    _handler.playbackState.listen((playbackState) {
      ref.read(playbackStateProvider.notifier).update((state) => playbackState);
    });
  }

  void _listenDuration() {
    _handler.player.positionStream.listen((position) {
      ref.read(progressStateProvider.notifier).update(
            (state) => ProgressBarState(
              current: position,
              buffered: state.buffered,
              total: state.total,
            ),
          );
    });
    _handler.player.durationStream.listen((position) {
      ref.read(progressStateProvider.notifier).update(
            (state) => ProgressBarState(
              current: state.current,
              buffered: state.buffered,
              total: position ?? state.total,
            ),
          );
    });
  }

  void _listenCurrentMediaItem() {
    _handler.mediaItem.listen((mediaItem) {
      ref.read(mediaItemProvider.notifier).update((state) => mediaItem);
    });
  }

  void _listenProcessingState() {
    _handler.player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        ref.read(audioControllerProvider).getNextSongAndSet();
      }
    });
  }
}
