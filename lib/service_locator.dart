import 'package:get_it/get_it.dart';
import 'package:just_audio_service_session/audio/player/audio_player_handler.dart';

/// DI, for access from everywhere through [getIt].
GetIt getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  getIt.registerSingleton<AudioPlayerHandler>(await initAudioService());
}
