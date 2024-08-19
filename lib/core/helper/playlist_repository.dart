abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();

  Future<Map<String, String>> fetchAnotherSong();
}

class DemoPlaylist extends PlaylistRepository {
  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = 3}) async {
    return List.generate(length, (index) => _nextSong());
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  var _songIndex = 0;
  static const _maxSongNumber = 16;

  Map<String, String> _nextSong() {
    _songIndex = (_songIndex % _maxSongNumber) + 1;
    return {
      'id': _songIndex.toString().padLeft(3, '0'),
      'title': 'Song $_songIndex',
      'album': 'SoundHelix',
      'imgUrl':
          'https://assets-global.website-files.com/5e6a544cadf84b1393e2e022/611cfe2fe8dfe7fe77ba50c4_cri_000000319870%20(1).jpeg',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/maukhik-audiobook.appspot.com/o/sample4.mp3?alt=media&token=96e5ae1e-6604-4fd7-9274-35bfef01e0cf',
    };
  }
}
