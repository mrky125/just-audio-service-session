import 'package:audio_service/audio_service.dart';

/// Provides access to a library of media items. In your app, this could come
/// from a database or web service.
class MediaLibrary {
  static const albumsRootId = 'albums';

  final items = <String, List<MediaItem>>{
    AudioService.browsableRootId: const [
      MediaItem(
        id: albumsRootId,
        title: "Albums",
        playable: false,
      ),
    ],
    albumsRootId: [
      item1,
      item10,
    ],
  };
}

final item1 = MediaItem(
  id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
  album: "Science Friday",
  title: "A Salute To Head-Scratching Science",
  artist: "Science Friday and WNYC Studios",
  // duration: const Duration(milliseconds: 5739820),
  artUri: Uri.parse(
      'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
);

final item2 = MediaItem(
  id: 'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
  album: "Science Friday",
  title: "From Cat Rheology To Operatic Incompetence",
  artist: "Science Friday and WNYC Studios",
  // duration: const Duration(milliseconds: 2856950),
  artUri: Uri.parse(
      'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
);

final item3 = MediaItem(
  id: 'https://s3.amazonaws.com/scifri-segments/scifri202011274.mp3',
  album: "Science Friday",
  title: "Laugh Along At Home With The Ig Nobel Awards",
  artist: "Science Friday and WNYC Studios",
  // duration: const Duration(milliseconds: 1791883),
  artUri: Uri.parse(
      'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
);

final item10 = MediaItem(
  id: 'https://firebasestorage.googleapis.com/v0/b/xalum1u.appspot.com/o/songs%2Fkamura_rock.mp3?alt=media&token=b08c55f3-fb87-4487-b01b-f1df22066e4f',
  album: 'My Song',
  title: 'Kamura Rock Cover',
  artUri: Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/xalum1u.appspot.com/o/songs%2Fkamura_art.jpeg?alt=media&token=28a5c2ff-1234-4363-b131-83f57895f24c'),
);

final item11 = MediaItem(
  id: 'https://firebasestorage.googleapis.com/v0/b/xalum1u.appspot.com/o/songs%2Fdonuts.mp3?alt=media&token=4c6114b9-3afe-4678-9510-7ef1d032d7ea',
  album: 'My Song',
  title: 'Circle Infinity Donuts',
  artUri: Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/xalum1u.appspot.com/o/songs%2Fdonuts_art.jpg?alt=media&token=51306dfc-707d-4c91-8ba6-21ef7f30722d'),
);

final item12 = MediaItem(
  id: 'https://firebasestorage.googleapis.com/v0/b/xalum1u.appspot.com/o/songs%2Fsnow.mp3?alt=media&token=bd9a695b-ed14-47ce-a651-d5c63aef9d44',
  album: 'My Song',
  title: 'Snow',
  artUri: Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/xalum1u.appspot.com/o/songs%2Fsnow_art.jpg?alt=media&token=41eb2164-1353-411a-aa48-87c65bf06bd3'),
);

final item13 = MediaItem(
  id: 'https://firebasestorage.googleapis.com/v0/b/xalum1u.appspot.com/o/songs%2Fsakura.mp3?alt=media&token=4ded93a8-1548-4ce0-ad57-ed7876912d0c',
  album: 'My Song',
  title: 'Sakura',
  artUri: Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/xalum1u.appspot.com/o/songs%2Fsakura_art.jpg?alt=media&token=eb22354b-5479-49d0-be00-516ba0c13418'),
);
