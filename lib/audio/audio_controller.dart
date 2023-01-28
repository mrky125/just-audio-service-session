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
}
