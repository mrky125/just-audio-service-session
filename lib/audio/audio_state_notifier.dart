import 'package:audio_service/audio_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio_service_session/audio/state/progress_bar_state.dart';

final playbackStateProvider =
    StateProvider.autoDispose((ref) => PlaybackState());

final progressStateProvider = StateProvider(
  (ref) => ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  ),
);

final mediaItemProvider = StateProvider<MediaItem?>((ref) => null);
