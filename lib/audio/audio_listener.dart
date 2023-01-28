import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio_service_session/audio/state/progress_bar_state.dart';

import '../service_locator.dart';
import 'player/audio_player_handler.dart';
import 'audio_state_notifier.dart';

final audioListenerProvider = Provider((ref) => AudioListener(ref: ref));

class AudioListener {
  AudioListener({required this.ref});

  final Ref ref;
  final _handler = getIt<AudioPlayerHandler>();

  void startListen() {
    _listenPlaybackState();
    _listenDuration();
  }

  void _listenPlaybackState() {
    _handler.playbackState.listen((playbackState) {
      ref.read(playbackStateProvider.notifier).update((state) => playbackState);
    });
  }

  void _listenDuration() {
    _handler.getPlayer().positionStream.listen((position) {
      ref.read(progressStateProvider.notifier).update(
            (state) => ProgressBarState(
              current: position,
              buffered: state.buffered,
              total: state.total,
            ),
          );
    });
    _handler.getPlayer().durationStream.listen((position) {
      ref.read(progressStateProvider.notifier).update(
            (state) => ProgressBarState(
              current: state.current,
              buffered: state.buffered,
              total: position ?? state.total,
            ),
          );
    });
  }
}
