import 'package:audiobooks/core/utils/constants.dart';
import 'package:audiobooks/feature/player/audio_player.dart';
import 'package:audiobooks/feature/player/widgets/playlist_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlaylistPage extends StatefulWidget {
  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My playlist (favourites)"),
          iconTheme: IconThemeData(color: cWhiteColor),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.featured_play_list_outlined,
                        size: 200,
                        color: Colors.black.withAlpha(10),
                      )),
                  Column(
                    children: [
                      Playlist(hasInternet: true),
                    ],
                  ),
                ],
              )),
        ));
  }
}
