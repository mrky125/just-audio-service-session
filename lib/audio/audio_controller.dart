import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../service_locator.dart';
import '../standard.dart';
import 'next_song_notifier.dart';
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

  Future<void> seek(Duration position) async {
    _handler.seek(position);
  }

  Future<void> skipToPrevious() async {
    _handler.skipToPrevious();
  }

  Future<void> skipToNext() async {
    _handler.skipToNext();
  }

  Future<void> setInitialItems() async {
    // set initial items
    _handler.setInitialItems();
  }

  Future<void> stop() async {
    await _handler.stop();
  }

  Future<void> stopAndRemoveAll() async {
    await _handler.stop();
    _handler.removeAll();
  }

  void getNextSongAndSet() async {
    final index = _handler.player.currentIndex;
    final nextItem = await ref
        .read(nextSongProvider.notifier)
        .getNextSong(currentIndex: index ?? 0);
    nextItem?.also((it) async {
      Logger().d('add next item to queue, $nextItem');
      await _handler.addQueueItem(it);
      await _handler.skipToNext();
      _handler.play();
    });
  }
}
