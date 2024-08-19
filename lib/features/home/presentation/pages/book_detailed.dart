import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/core/widgets/custom_toast.dart';
import 'package:audiobooks/core/utils/constants.dart';
import 'package:audiobooks/core/utils/functions.dart';
import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:audiobooks/features/home/presentation/bloc/book_detailed/book_detailed_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookDetailedPage extends StatefulWidget {
  final Book? book;

  const BookDetailedPage({super.key, required this.book});

  static Widget screen(Book? book) {
    return BlocProvider(
      create: (context) => di<BookDetailedBloc>(),
      child: BookDetailedPage(book: book),
    );
  }

  @override
  State<BookDetailedPage> createState() => _BookDetailedPageState();
}

class _BookDetailedPageState extends State<BookDetailedPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<BookDetailedBloc>(context)
        .add(LoadBookEvent(book: widget.book));
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: Text("Book Details"),
        iconTheme: IconThemeData(color: cWhiteColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            Center(
              child: Container(
                decoration: BoxDecoration(boxShadow: [boxShadow60]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    book?.imgUrl ?? '',
                    height: 250.0,
                    width: 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              book?.title ?? '-',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            BlocConsumer<BookDetailedBloc, BookDetailedState>(
              listener: (context, state) {
                if (state.status == BookDetailedStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Download failed. Please try again.')),
                  );
                } else if (state.status == BookDetailedStatus.noInternet) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No internet connection.')),
                  );
                } else if (state.status == BookDetailedStatus.success &&
                    state.isDownloaded) {
                  CustomToast.showToast(
                      '${book?.title} downloaded successfully!');
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.status == BookDetailedStatus.loading
                      ? null
                      : () async {
                          if (state.isDownloaded) {
                            var result =
                                await showAlertText(context, "Are you sure to remove?") ??
                                    false;
                            if (result) {
                              BlocProvider.of<BookDetailedBloc>(context)
                                  .add(RemoveBookEvent(book: book));
                            }
                          } else {
                            BlocProvider.of<BookDetailedBloc>(context)
                                .add(DownloadBookEvent(book: book));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        state.isDownloaded ? Colors.red : Colors.blue,
                  ),
                  child: state.status == BookDetailedStatus.loading
                      ? const CupertinoActivityIndicator()
                      : Text(
                          state.isDownloaded
                              ? 'Remove from playlist'
                              : 'Download/Add Playlist',
                          style: TextStyle(color: cWhiteColor),
                        ),
                );
              },
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                loremIpsumText,
                style: const TextStyle(
                    fontSize: 15.0, fontStyle: FontStyle.italic),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
