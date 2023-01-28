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

  /// just_audioのseekToPreviousは前のアイテムがある時しか行われないので、自前で処理を定義している
  /// 前のアイテムがない時は自前でseekして先頭に戻す
  Future<void> skipToPrevious() async {
    if (_handler.player.hasPrevious) {
      _handler.skipToPrevious();
    } else {
      seek(Duration.zero);
    }
  }

  /// skipToPreviousと同じく自前で処理し、次アイテムがない時は末尾までseekする
  Future<void> skipToNext() async {
    if (_handler.player.hasNext) {
      _handler.skipToNext();
    } else {
      // nullだとjust_audioの仕様でpositionがゼロになってしまうので、nullじゃなければ実行
      final duration = _handler.mediaItem.value?.duration;
      if (duration != null) seek(duration);
    }
  }

  Future<void> setInitialItems() async {
    // set initial items
    _handler.setInitialItems();
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
