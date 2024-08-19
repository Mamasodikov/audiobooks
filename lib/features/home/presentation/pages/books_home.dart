import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/core/utils/constants.dart';
import 'package:audiobooks/features/home/data/models/category_model.dart';
import 'package:audiobooks/features/home/presentation/bloc/books_home/books_home_bloc.dart';
import 'package:audiobooks/features/home/presentation/pages/about.dart';
import 'package:audiobooks/features/home/presentation/pages/playlist_page.dart';
import 'package:audiobooks/features/home/presentation/widgets/book_widgets.dart';
import 'package:audiobooks/features/home/presentation/widgets/custom_cards_row.dart';
import 'package:audiobooks/features/player/widgets/draggable_bottom_sheet.dart';
import 'package:audiobooks/features/player/widgets/playlist_widget.dart';
import 'package:audiobooks/generated/assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BooksHomePage extends StatefulWidget {
  const BooksHomePage({super.key});

  static Widget screen() {
    return BlocProvider(
        create: (context) => di<BooksHomeBloc>(), child: BooksHomePage());
  }

  @override
  State<BooksHomePage> createState() => _BooksHomePageState();
}

class _BooksHomePageState extends State<BooksHomePage> {
  @override
  void initState() {
    reInitialize();
    super.initState();
  }

  Future<void> reInitialize() async {
    return BlocProvider.of<BooksHomeBloc>(context).add(getBooksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cFirstColor,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: reInitialize,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: BlocConsumer<BooksHomeBloc, BooksHomeState>(
                    builder: (BuildContext context, state) {
                      if (state.status == BooksHomeStatus.loading) {
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                                child: CupertinoActivityIndicator(
                              radius: 20,
                              color: cWhiteColor,
                            )));
                      } else if (state.status == BooksHomeStatus.success) {
                        final categories = state
                            .categories; // Assuming this is a list of Category objects

                        return Column(
                          children: [
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'UIC',
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: cWhiteColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AudioBooks',
                                  style: TextStyle(
                                      fontSize: 30, color: cWhiteColor),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Image.asset(Assets.assetsAudioBook,
                                height: 120, width: 120, color: cWhiteColor),
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: CardRow(
                                onCard1Tap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PlaylistPage()));
                                },
                                onCard2Tap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AboutPage()));
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: categories?.length,
                              padding: EdgeInsets.only(bottom: 250),
                              itemBuilder: (context, index) {
                                return CategoryCard(
                                    category: categories?[index] ?? Category());
                              },
                            ),
                          ],
                        );
                      } else if (state.status == BooksHomeStatus.noInternet) {
                        return Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              'Playlist',
                              style:
                                  TextStyle(fontSize: 30, color: cWhiteColor),
                            ),
                            Container(
                                height: MediaQuery.of(context).size.height,
                                child: Playlist(
                                  hasInternet: false,
                                  onRefresh: reInitialize,
                                )),
                          ],
                        );
                      } else {
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                                child: Text(
                              'Initializing...',
                              style: TextStyle(color: cWhiteColor),
                            )));
                      }
                    },
                    listener: (BuildContext context, BooksHomeState state) {
                      if (state.status == BooksHomeStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to load books')),
                        );
                      }
                    },
                  ),
                ),
              ),
              DraggableBottomSheet()
            ],
          ),
        ),
      ),
    );
  }
}
