import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/core/utils/constants.dart';
import 'package:audiobooks/features/player/audio_player.dart';
import 'package:audiobooks/features/player/page_manager.dart';
import 'package:flutter/material.dart';

import 'playlist_widget.dart';

class DraggableBottomSheet extends StatefulWidget {
  const DraggableBottomSheet({super.key});

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

// it's a stateful widget!
class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  final _sheet = GlobalKey();
  final _controller = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  final pageManager = di<PageManager>();

  void _onChanged() {
    final currentSize = _controller.size;
    if (currentSize <= 0.05) _collapse();
  }

  void _collapse() => _animateSheet(sheet.snapSizes!.first);

  void _anchor() => _animateSheet(sheet.snapSizes!.last);

  void _expand() => _animateSheet(sheet.maxChildSize);

  void _hide() => _animateSheet(sheet.minChildSize);

  void _animateSheet(double size) {
    _controller.animateTo(
      size,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  DraggableScrollableSheet get sheet =>
      (_sheet.currentWidget as DraggableScrollableSheet);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: pageManager.playlistNotifier,
        builder: (context, playlistItems, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Visibility(
                visible: playlistItems.length > 0,
                child: DraggableScrollableSheet(
                  key: _sheet,
                  initialChildSize: 190 / constraints.maxHeight,
                  maxChildSize: 1,
                  minChildSize: 0,
                  expand: true,
                  snap: true,
                  snapSizes: [
                    200 / constraints.maxHeight,
                    0.5,
                  ],
                  controller: _controller,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                          color: cFourthColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          boxShadow: [boxShadow60]),
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverList.list(
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: AudioPlayerPage(),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                  height: 600,
                                  child: Column(
                                    children: [
                                      Playlist(hasInternet: true),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        });
  }
}
