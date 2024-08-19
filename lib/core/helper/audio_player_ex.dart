import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerExample extends StatefulWidget {
  const AudioPlayerExample({super.key});

  @override
  State<AudioPlayerExample> createState() => _AudioPlayerExampleState();
}

class _AudioPlayerExampleState extends State<AudioPlayerExample> {

  String musicUrl = "https://firebasestorage.googleapis.com/v0/b/maukhik-audiobook.appspot.com/o/sample1.mp3?alt=media&token=4cdf4d9c-f319-4f20-a011-395f355b96bd"; // Insert your music URL
  String thumbnailImgUrl = "https://assets-global.website-files.com/5e6a544cadf84b1393e2e022/611cfe2fe8dfe7fe77ba50c4_cri_000000319870%20(1).jpeg"; // Insert your thumbnail URL
  var player = AudioPlayer();
  bool loaded = false;
  bool playing = false;

  void loadMusic() async {
    await player.setUrl(musicUrl);
    setState(() {
      loaded = true;
    });
  }

  void playMusic() async {
    setState(() {
      playing = true;
    });
    await player.play();
  }

  void pauseMusic() async {
    setState(() {
      playing = false;
    });
    await player.pause();
  }

  @override
  void initState() {
    loadMusic();
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Player"),
      ),
      body: Column(
        children: [
          const Spacer(
            flex: 2,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              thumbnailImgUrl,
              height: 350,
              width: 350,
              fit: BoxFit.cover,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StreamBuilder(
                stream: player.positionStream,
                builder: (context, snapshot1) {
                  final Duration duration = loaded
                      ? snapshot1.data as Duration
                      : const Duration(seconds: 0);
                  return StreamBuilder(
                      stream: player.bufferedPositionStream,
                      builder: (context, snapshot2) {
                        final Duration bufferedDuration = loaded
                            ? snapshot2.data as Duration
                            : const Duration(seconds: 0);
                        return SizedBox(
                          height: 30,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ProgressBar(
                              progress: duration,
                              total:
                              player.duration ?? const Duration(seconds: 0),
                              buffered: bufferedDuration,
                              timeLabelPadding: -1,
                              timeLabelTextStyle: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                              progressBarColor: Colors.red,
                              baseBarColor: Colors.grey[200],
                              bufferedBarColor: Colors.grey[350],
                              thumbColor: Colors.red,
                              onSeek: loaded
                                  ? (duration) async {
                                await player.seek(duration);
                              }
                                  : null,
                            ),
                          ),
                        );
                      });
                }),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  onPressed: loaded
                      ? () async {
                    if (player.position.inSeconds >= 10) {
                      await player.seek(Duration(
                          seconds: player.position.inSeconds - 10));
                    } else {
                      await player.seek(const Duration(seconds: 0));
                    }
                  }
                      : null,
                  icon: const Icon(Icons.fast_rewind_rounded)),
              Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.red),
                child: IconButton(
                    onPressed: loaded
                        ? () {
                      if (playing) {
                        pauseMusic();
                      } else {
                        playMusic();
                      }
                    }
                        : null,
                    icon: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    )),
              ),
              IconButton(
                  onPressed: loaded
                      ? () async {
                    if (player.position.inSeconds + 10 <=
                        player.duration!.inSeconds) {
                      await player.seek(Duration(
                          seconds: player.position.inSeconds + 10));
                    } else {
                      await player.seek(const Duration(seconds: 0));
                    }
                  }
                      : null,
                  icon: const Icon(Icons.fast_forward_rounded)),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const Spacer(
            flex: 2,
          )
        ],
      ),
    );
  }
}
