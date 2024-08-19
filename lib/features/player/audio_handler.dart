import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/core/utils/functions.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'uz.flutterdev.audiobooks',
      androidNotificationChannelName: 'AudioBooks UIC',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _prefs = di<SharedPreferences>();
  final _playlist = ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices!.indexOf(index);
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices!.indexOf(index);
      }
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    _playlist.add(audioSource);

    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    final audioUrl = mediaItem.extras!['audioUrl'] as String;

    // Check if the audioUrl is a web URL or a local file path
    if (isWebUrl(audioUrl)) {
      return AudioSource.uri(
        Uri.parse(audioUrl),
        tag: mediaItem,
      );
    } else {
      ///Uncomment when use path or url instead of asset
      // var item = mediaItem.copyWith(artUri: Uri.file(mediaItem.extras?['artUrl']));
      return AudioSource.file(
        audioUrl,
        tag: mediaItem,
      );
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    _playlist.removeAt(index);

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    // Get the current list of media items in the queue
    var list = queue.value;

    // Find the index of the media item to be removed
    final index = list.indexWhere((item) => item.id == mediaItem.id);

    if (index != -1) {
      // Remove the item from the Just Audio playlist
      _playlist.removeAt(index);

      // Notify the system
      final newQueue = List<MediaItem>.from(queue.value)..removeAt(index);
      queue.add(newQueue);
    }

    return super.removeQueueItem(mediaItem);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future<dynamic> customAction(String name,
      [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    } else if (name == 'currentIndex') {
      return _player.currentIndex ?? 0;
    } else if (name == 'reorder') {
      await _playlist.move(extras?['currentIndex'], extras?['newIndex']);

      ///Workaround for resetting playback position
      if (_player.playing) {
        await _player.stop();
        await _player.play();
      } else {
        await _player.stop();
        return super.stop();
      }
    } else if (name == 'clearPlaylist') {
      await _playlist.clear();
      return queue.value.clear();
      // await _player.stop();
      // return super.stop();
    } else if (name == 'loadLastAudio') {

      ///Read prefs for the current saved audio data
      var currentAudioId = _prefs.getString('currentAudioId');
      var positionString = _prefs.getString('positionString');

      if (currentAudioId != null && positionString != null) {
        // Get the current list of media items in the queue
        var list = queue.value;

        // Find the index of the media item to be removed
        final index = list.indexWhere((item) => item.id == currentAudioId);

        print("================= positionString: $positionString");
        if (index != -1) {
          print("=== loadLastAudio: setting last position");

          Duration duration = Duration(
            hours: int.parse(positionString.split(":")[0]),
            minutes: int.parse(positionString.split(":")[1]),
            seconds: int.parse(positionString.split(":")[2].split(".")[0]),
            milliseconds: int.parse(
                positionString.split(":")[2].split(".")[1].substring(0, 3)),
          );

          await skipToQueueItem(index);
          await seek(duration);

          return duration;

        } else {
          print("=== loadLastAudio: couldn't find data or ID");
        }
      } else {
        print("=== loadLastAudio: no audio data");
      }
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    await _player.stop();
    return super.onTaskRemoved();
  }
}
