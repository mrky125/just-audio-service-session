import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../service_locator.dart';
import 'player/audio_player_handler.dart';

final audioControllerProvider = Provider((ref) => AudioController(ref: ref));

/// Wraps [AudioPlayerHandler]
class AudioController {
  AudioController({required this.ref});

  final Ref ref;
  final _handler = getIt<AudioPlayerHandler>();

  Future<void> play() async {
    _handler.play();
  }

  Future<void> pause() async {
    _handler.pause();
  }
}
