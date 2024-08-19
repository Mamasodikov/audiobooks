
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/core/widgets/custom_toast.dart';
import 'package:audiobooks/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'page_manager.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CurrentSongTitle(),
        AudioProgressBar(),
        AudioControlButtons(),
      ],
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = di<PageManager>();
    return ValueListenableBuilder<MediaItem>(
      valueListenable: pageManager.currentSongNotifier,
      builder: (_, currentSong, __) {
        return SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Divider(
                  indent: 120,
                  endIndent: 120,
                  thickness: 2,
                ),
                Flexible(
                    child: Text(currentSong.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Player controllers and widgets

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = di<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          RepeatButton(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = di<PageManager>();
    return ValueListenableBuilder<RepeatState>(
      valueListenable: pageManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = const Icon(Icons.repeat, color: Colors.grey);
            break;
          case RepeatState.repeatSong:
            icon = const Icon(Icons.repeat_one);
            break;
          case RepeatState.repeatPlaylist:
            icon = const Icon(Icons.repeat);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: () {
            switch (value) {
              case RepeatState.off:
                CustomToast.showToast('Repeat this audio');
                break;
              case RepeatState.repeatSong:
                CustomToast.showToast('Repeat all playlist');
                break;
              case RepeatState.repeatPlaylist:
                CustomToast.showToast('Repeating is off');
                break;
            }
            pageManager.repeat();
          },
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = di<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: (isFirst) ? null : pageManager.previous,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = di<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return Container(
              decoration: BoxDecoration(boxShadow: [boxShadowPlay]),
              child: IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 32.0,
                onPressed: pageManager.play,
              ),
            );
          case ButtonState.playing:
            return Container(
              decoration: BoxDecoration(boxShadow: [boxShadowStop]),
              child: IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 32.0,
                onPressed: pageManager.pause,
              ),
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = di<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (isLast) ? null : pageManager.next,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = di<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled)
              ? const Icon(Icons.shuffle)
              : const Icon(Icons.shuffle, color: Colors.grey),
          onPressed: () {
            if (isEnabled) {
              CustomToast.showToast('Shuffling is off');
            } else {
              CustomToast.showToast('Shuffling is on');
            }
            pageManager.shuffle();
          },
        );
      },
    );
  }
}
