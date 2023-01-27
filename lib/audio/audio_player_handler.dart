import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';

/// [AudioHandler] を初期化し、システムのコントロールセンターと連携する
Future<AudioHandler> initAudioService() async {
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

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }
}
