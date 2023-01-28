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
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(final Duration? position, {int? index}) async {
    _player.seek(position, index: index);
  }

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToNext() => _player.seekToNext();
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
