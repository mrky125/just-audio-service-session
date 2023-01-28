import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

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
  final _playlist = ConcatenatingAudioSource(children: []);
  final _mediaLibrary = MediaLibrary();

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    // Propagate all events from the audio player to AudioService clients.
    _player.playbackEventStream.listen(_broadcastState);

    await updateQueue(_mediaLibrary.items[MediaLibrary.albumsRootId]!);
    await _player.setAudioSource(_playlist);
  }

  AudioPlayer getPlayer() => _player;

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    // final queueIndex = getQueueIndex(
    //   event.currentIndex,
    //   _player.shuffleModeEnabled,
    //   _player.shuffleIndices,
    // );
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
      // queueIndex: queueIndex,
    ));
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await _playlist.clear();
    await _playlist.addAll(_itemsToSources(queue));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);
}

AudioSource _itemToSource(MediaItem mediaItem) {
  final audioSource = AudioSource.uri(Uri.parse(mediaItem.id));
  // _mediaItemExpando[audioSource] = mediaItem;
  return audioSource;
}

List<AudioSource> _itemsToSources(List<MediaItem> mediaItems) =>
    mediaItems.map(_itemToSource).toList();