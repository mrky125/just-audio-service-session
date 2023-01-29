import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

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

  // Refer to: https://github.com/ryanheise/audio_service/tree/minor/audio_service/example
  Stream<ProgressBarState> get _progressStateStream => Rx.combineLatest3(
        _handler.player.positionStream,
        _handler.player.bufferedPositionStream,
        _handler.player.durationStream,
        (current, buffered, total) => ProgressBarState(
          current: current,
          buffered: buffered,
          total: total ?? Duration.zero,
        ),
      );

  void startListen() {
    _listenPlaybackState();
    _listenProgressState();
    _listenCurrentMediaItem();
    _listenProcessingState();
  }

  void _listenPlaybackState() {
    _handler.playbackState.listen((playbackState) {
      ref.read(playbackStateProvider.notifier).update((state) => playbackState);
    });
  }

  void _listenProgressState() {
    _progressStateStream.listen((progressState) {
      ref.read(progressStateProvider.notifier).update((state) => progressState);
      // 全体の長さが取得できていて（ゼロでなくて）曲の末尾に到達、かつプレイリストも末尾なら、次のアイテムを取得する
      // NOTE: 一時停止状態で次へボタンじゃなくてシークバーで末尾に移動すると、ミリ秒の値が差分あって末尾判定してないけど、どうするかはプロダクトの仕様次第
      //  ex) progress: 0:01:30.000000, 0:01:30.644000, hasNext: false
      if (progressState.total.inSeconds > 0) {
        if (progressState.current >= progressState.total) {
          if (!_handler.player.hasNext) {
            ref.read(audioControllerProvider).getNextSongAndSet();
          }
        }
      }
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
        // NOTE: playing=trueじゃないと検知できない
        // _listenProgressStateの方で再生中問わず末尾検出できたので、そっちだけで済んだ
        // ref.read(audioControllerProvider).getNextSongAndSet();
      }
    });
  }
}
