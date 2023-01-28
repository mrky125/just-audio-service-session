import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  }

  void _listenPlaybackState() {
    _handler.playbackState.listen((playbackState) {
      ref.read(playbackStateProvider.notifier).update((state) => playbackState);
    });
  }
}