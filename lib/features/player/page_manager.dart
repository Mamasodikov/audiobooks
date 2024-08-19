import 'dart:async';

import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/features/home/data/datasources/home_local_datasource.dart';
import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongNotifier =
      ValueNotifier<MediaItem>(MediaItem(id: '-', title: '-'));
  final playlistNotifier = ValueNotifier<List<MediaItem>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = di<AudioHandler>();
  final _prefs = di<SharedPreferences>();

  // Events: Calls coming from the UI
  Future<void> init() async {
    await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadPlaylist() async {
    // final songRepository = di<PlaylistRepository>();
    // final playlist = await songRepository.fetchInitialPlaylist();

    // Make sure to call this after all dependencies have been registered
    await di.isReady<DBHelper>(); // Ensure DBHelper is ready before using

    DBHelper database = di();
    final List<Book> playlist = await database.getPlaylist();

    print("Playlist loaded from local DB...");

    // Convert List<Book> to List<Map<String, String>>
    final List<Map<String, String>> playlistAsMapList =
        playlist.map((book) => book.toMap()).toList();

    final mediaItems = playlistAsMapList
        .map((song) => MediaItem(
              id: song['id'] ?? '',
              title: song['title'] ?? '',
              extras: {
                'author': song['author'],
                'audioUrl': song['audioUrl'],
                'imgUrl': song['imgUrl']
              },
            ))
        .toList();
    await _audioHandler.customAction('clearPlaylist');
    await _audioHandler.addQueueItems(mediaItems);
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongNotifier.value = MediaItem(id: '', title: '');
      } else {
        // final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = playlist;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() async {
    AudioService.position.listen((position) async {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );

      ///Save current position and song
      final currentIndex = await _audioHandler.customAction('currentIndex');
      final currentAudioId = currentSongNotifier.value.id;
      final positionString = position.toString();

      ///Save to prefs
      print(
          "ID: $currentAudioId\nIndex: $currentIndex\nPosition:$positionString");


      // Check if earlier prefs values exist
      final existingIndex = _prefs.getInt('currentIndex');
      final existingPositionString = _prefs.getString('positionString');

      if (existingIndex == null || existingPositionString == null) {
        // Write 0 index and 0 duration if earlier prefs values do not exist
        print("ID: $currentAudioId\nIndex: 0\nPosition: 0:00:00.000000");

        _prefs.setString('currentAudioId', currentAudioId);
        _prefs.setString('positionString', Duration.zero.toString());
        _prefs.setInt('currentIndex', 0);
      } else {
        // Check if currentIndex and position are not zero before writing
        if (currentIndex != 0 || position.inMilliseconds != 0) {
          print("ID: $currentAudioId\nIndex: $currentIndex\nPosition: $positionString");

          // Write actual values to prefs
          _prefs.setString('currentAudioId', currentAudioId);
          _prefs.setString('positionString', positionString);
          _prefs.setInt('currentIndex', currentIndex);
        }}

    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongNotifier.value = mediaItem ?? MediaItem(id: '-', title: '-');
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() async {

    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();

  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();

  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> add(Map<String, String> audioMap) async {
    final mediaItem = MediaItem(
      id: audioMap['id'] ?? '',
      title: audioMap['title'] ?? '',
      extras: {
        'author': audioMap['author'],
        'audioUrl': audioMap['audioUrl'],
        'imgUrl': audioMap['imgUrl']
      },
    );
    _audioHandler.addQueueItem(mediaItem);
  }

  void remove(Map<String, String> audioMap) async {
    final mediaItem = MediaItem(
      id: audioMap['id'] ?? '',
      title: audioMap['title'] ?? '',
      extras: {
        'author': audioMap['author'],
        'audioUrl': audioMap['audioUrl'],
        'imgUrl': audioMap['imgUrl']
      },
    );
    try {
      _audioHandler.removeQueueItem(mediaItem);
    } catch (e) {
      print(e);
    }
  }

  void reorderPlaylist(int currentIndex, int newIndex) {
    _audioHandler.customAction(
        'reorder', {'currentIndex': currentIndex, 'newIndex': newIndex});
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }

  Future<dynamic> loadLastAudio() async {

    Duration? duration = await _audioHandler.customAction('loadLastAudio');

    if (duration != null) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: duration,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    }
  }

  void skipToQueueItem(int index) {
    _audioHandler.skipToQueueItem(index);
  }
}
