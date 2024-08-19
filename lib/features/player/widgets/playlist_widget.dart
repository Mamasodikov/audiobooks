import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/core/widgets/custom_toast.dart';
import 'package:audiobooks/core/utils/constants.dart';
import 'package:audiobooks/core/utils/functions.dart';
import 'package:audiobooks/features/player/page_manager.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class Playlist extends StatefulWidget {
  final bool hasInternet;
  final VoidCallback? onRefresh; // Optional callback

  const Playlist({
    Key? key,
    required this.hasInternet,
    this.onRefresh, // Constructor accepts the optional onRefresh callback
  }) : super(key: key);

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  PageManager pageManager = di();

  @override
  void initState() {
    ///Timer to wait playlist loader sets default values, after that, set ours
    Timer(Duration(seconds: 1), () {
      pageManager.loadLastAudio();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.hasInternet
        ? Expanded(
      child: ValueListenableBuilder<List<MediaItem>>(
        valueListenable: pageManager.playlistNotifier,
        builder: (context, playlistItems, _) {
          return ValueListenableBuilder<MediaItem>(
            valueListenable: pageManager.currentSongNotifier,
            builder: (_, currentBook, __) {
              var currentSongId = currentBook.id;

              return ReorderableListView(
                onReorder: (int oldIndex, int newIndex) {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  pageManager.reorderPlaylist(oldIndex, newIndex);
                },
                children: List.generate(playlistItems.length, (index) {
                  return Column(
                    key: Key('$index'),
                    children: [
                      ZoomTapAnimation(
                        onTap: () {
                          pageManager.skipToQueueItem(index);
                          pageManager.play();
                        },
                        child: Container(
                          color: currentSongId == playlistItems[index].id
                              ? cGrayColor0
                              : cWhiteColor,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 5),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    playlistItems[index]
                                        .extras?['imgUrl'] ??
                                        '',
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${index + 1}. ${playlistItems[index].title}',
                                    // Including the index
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    var result = await showAlertText(
                                        context,
                                        "Are you sure to remove?") ??
                                        false;
                                    if (result) {
                                      var resultDB =
                                      await deleteFromDBAndPlaylist(
                                          database: di(),
                                          pageManager: pageManager,
                                          book:
                                          convertMediaItemToBook(
                                              playlistItems[
                                              index]));
                                      if (resultDB)
                                        CustomToast.showToast(
                                            "Successfully removed from playlist");
                                      else
                                        CustomToast.showToast(
                                            "Failed to remove from playlist");
                                    }
                                  },
                                  icon: Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.drag_handle,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  );
                }),
              );
            },
          );
        },
      ),
    )
        : ValueListenableBuilder<List<MediaItem>>(
      valueListenable: pageManager.playlistNotifier,
      builder: (context, playlistItems, _) {
        return ValueListenableBuilder<MediaItem>(
            valueListenable: pageManager.currentSongNotifier,
            builder: (_, currentBook, __) {
              var currentSongId = currentBook.id;
              return Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 400,
                      child: FadingEdgeScrollView.fromScrollView(
                        child: GridView.builder(
                          controller: ScrollController(),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1 / 1.5),
                          shrinkWrap: true,
                          itemCount: playlistItems.length,
                          // padding: EdgeInsets.only(bottom: 250),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.all(2.0),
                              child: ZoomTapAnimation(
                                onTap: () {
                                  pageManager.skipToQueueItem(index);
                                  pageManager.play();
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  color: currentSongId ==
                                      playlistItems[index].id
                                      ? Colors.amber
                                      : cWhiteColor,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          child: Image.asset(
                                            playlistItems[index]
                                                .extras?['imgUrl'] ??
                                                '',
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          playlistItems[index].title,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 3,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No internet, turn on internet and get newest books',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: cGrayColor0,
                      ),
                    ),
                    SizedBox(height: 5),
                    CupertinoButton(
                      child: Text(
                        "Refresh",
                        style: TextStyle(color: cGrayColor0),
                      ),
                      color: cGrayColor0.withAlpha(80),
                      onPressed: widget.onRefresh ??
                              () {
                            // Default action if no callback is provided
                            CustomToast.showToast(
                                'Refresh button clicked');
                          },
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}