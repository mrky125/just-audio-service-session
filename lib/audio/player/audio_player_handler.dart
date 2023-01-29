import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import '../data/media_library.dart';

/// [AudioPlayerHandler] を初期化し、システムのコントロールセンターと連携する
Future<AudioPlayerHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'just-audio-service-session',
      androidNotificationChannelName: 'just-audio-service-session',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

/// The implementation of [AudioPlayerHandler].
///
/// This handler is backed by a just_audio player. The player's effective
/// sequence is mapped onto the handler's queue, and the player's state is
/// mapped onto the handler's state.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  /// constructor
  AudioPlayerHandler() {
    _init();
  }

  final _player = AudioPlayer();
  AudioPlayer get player => _player;
  final _playlist = ConcatenatingAudioSource(children: []);
  final _mediaLibrary = MediaLibrary();

  // This can be replaced with like below.
  // ```final _mediaItems = Expando<MediaItem>();```
  final _mediaItems = <AudioSource, MediaItem>{};

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _broadcastItemChanges();
    _broadcastQueue();
    _player.playbackEventStream.listen((event) {
      _broadcastItemDuration(event);
      _broadcastState(event);
    });
  }

  /// Broadcast media item changes.
  void _broadcastItemChanges() {
    Rx.combineLatest2<int?, List<MediaItem>, MediaItem?>(
      _player.currentIndexStream,
      queue,
      (index, queue) {
        final newItem =
            (index != null && index < queue.length) ? queue[index] : null;
        Logger().d(
            'item changed, index: $index, length: ${queue.length}, item: $newItem');
        return newItem;
      },
    ).whereType<MediaItem>().distinct().listen((item) {
      Logger().d('finally broadcast an unique item: $item');
      mediaItem.add(item);
    });
  }

  /// Broadcast the current queue to the service.
  void _broadcastQueue() {
    _player.sequenceStream
        .map((sequence) => sequence ?? [])
        .map((sequence) => sequence
            .map((source) => _mediaItems[source]!)
            .toList()) // TODO: null handling?
        .pipe(queue); // important!!!
  }

  /// Update current media item duration.
  void _broadcastItemDuration(PlaybackEvent event) {
    // ネットワークから取得したアイテムは、プレーヤーにセット前だとDurationがわからないケースがあるので、ここで取得して情報を更新する
    mediaItem.add(queue.value[event.currentIndex ?? 0].copyWith(
      duration: event.duration,
    ));
  }

  /// Propagate all events from the audio player to AudioService clients. (except duration)
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        // 3つ以内なら、引数`androidCompactActionIndices`を未設定でも、
        // 通知センターで縮小表示時にボタン3つ全て表示される
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  Future<void> setInitialItems() async {
    await updateQueue(_mediaLibrary.items[MediaLibrary.albumsRootId]!);
    // Can get duration of first item in queue.
    final duration = await _player.setAudioSource(_playlist);
    Logger().d('duration: $duration, length: ${queue.value.length}');
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await _playlist.clear();
    final audioSources = queue.toAudioSources(action: (source, index) {
      _mediaItems[source] = queue[index];
    });
    await _playlist.addAll(audioSources);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(mediaItem.toAudioSource(action: (source) {
      _mediaItems[source] = mediaItem;
    }));
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    await _playlist.removeAt(index);
  }

  @override
  Future<void> play() async {
    _player.play();
    await playIfTappedEmptyNotification();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(final Duration? position, {int? index}) async {
    await _player.seek(position, index: index);
  }

  /// just_audioのseekToPreviousは前のアイテムがある時しか行われないので、自前で処理を定義している
  /// 前のアイテムがあり、開始3秒間の場合は前のアイテムに戻る
  /// それ以外前の場合は自前でseekして先頭に戻す
  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious && player.position.inSeconds < 3) {
        _player.seekToPrevious();
    } else {
      seek(Duration.zero);
    }
  }

  /// skipToPreviousと同じく自前で処理し、次アイテムがない時は末尾までseekする
  @override
  Future<void> skipToNext() async {
    final duration = mediaItem.value?.duration;
    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (duration != null) {
      await seek(duration);
    }
  }

  @override
  Future<void> stop() async {
    // この後にmediaItemなど各種BehaviorSubjectをリセットするなら、正しく処理させるためにawait必要
    await _player.stop();
  }

  Future<void> removeAll() async {
    // 今の実装だと最初にupdateQueueを呼ぶからそこでclearされるけど、そうじゃなくなった時のために
    _playlist.clear();
    // 現在表示中のアイテムを消すため（iOSはOKだけどAndroidは通知センターに残ってしまい、そこから不正な状態で再生できてしまう）
    mediaItem.add(null);
    // TODO: reset other subjects.
  }

  // AndroidでstopとremoveAll後も通知センターに残っててコントトールボタンを押された時を想定
  // TODO: 最後に再生したアイテムとキューを覚えておきたい
  Future<void> playIfTappedEmptyNotification() async {
    Logger().d(
        'item: ${mediaItem.value}, queue length: ${queue.length}, playlist length: ${_playlist.length}, state: ${playbackState.value.processingState}');
    if (mediaItem.value == null &&
        queue.value.isEmpty &&
        _playlist.length == 0 &&
        playbackState.value.processingState == AudioProcessingState.idle) {
      await setInitialItems();
      _player.play();
    }
  }
}

extension ItemToSource on MediaItem {
  AudioSource toAudioSource({
    void Function(AudioSource)? action,
  }) {
    final source = AudioSource.uri(Uri.parse(id));
    if (action != null) action(source);
    return source;
  }
}

extension ItemsToSources on List<MediaItem> {
  List<AudioSource> toAudioSources({
    void Function(AudioSource, int)? action,
  }) {
    return asMap().entries.map((e) {
      return e.value.toAudioSource(action: (source) {
        if (action != null) action(source, e.key);
      });
    }).toList();
  }
}
