import 'package:audio_service/audio_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final playbackStateProvider =
    StateProvider.autoDispose((ref) => PlaybackState());