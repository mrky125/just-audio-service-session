import 'package:audio_service/audio_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio_service_session/audio/data/media_library.dart';

final nextSongProvider = StateNotifierProvider((ref) => NextSongNotifier());

class NextSongNotifier extends StateNotifier {
  // state is unused.
  NextSongNotifier() : super(null);

  // To exclude requests from the same index
  int? processingIndex;

  Future<MediaItem?> getNextSong({
    int currentIndex = 0,
  }) async {
    if (currentIndex == processingIndex) return null;
    processingIndex = currentIndex;
    // assumed fetching form network.
    await Future.delayed(const Duration(seconds: 1));
    switch (currentIndex) {
      case 0:
        return item10;
      case 1:
        return item2;
      default:
        return item11;
    }
  }
}
