import 'package:audiobooks/core/di.dart';
import 'package:audiobooks/core/network/network_info.dart';
import 'package:audiobooks/core/utils/functions.dart';
import 'package:audiobooks/feature/home/data/datasources/home_local_datasource.dart';
import 'package:audiobooks/feature/home/data/models/book_model.dart';
import 'package:audiobooks/feature/player/page_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'book_detailed_event.dart';

part 'book_detailed_state.dart';

class BookDetailedBloc extends Bloc<BookDetailedEvent, BookDetailedState> {
  final NetworkInfo networkInfo;
  final Dio dio;
  final PageManager pageManager;

  BookDetailedBloc(
      {required this.pageManager, required this.networkInfo, required this.dio})
      : super(BookDetailedState.initial()) {
    on<LoadBookEvent>(getInitialState);
    on<DownloadBookEvent>(downloadAndAddPlaylist);
    on<RemoveBookEvent>(removeFileAndPlaylist);
  }

  getInitialState(LoadBookEvent event, Emitter<BookDetailedState> emit) async {
    try {
      ///Query local DB and pass if it's in playlist or not
      DBHelper database = di();
      var book = event.book ?? Book();
      var bookId = book.id ?? '-';

      emit(state.copyWith(status: BookDetailedStatus.loading));

      var result = await database.getBookById(bookId);
      if (result != null) {
        emit(state.copyWith(
            status: BookDetailedStatus.initial,
            isDownloaded: true,
            localBook: result));
      } else {
        emit(state.copyWith(
            status: BookDetailedStatus.initial, isDownloaded: false));
      }
    } catch (e) {
      print(e);
      emit(
          state.copyWith(status: BookDetailedStatus.failure, message: "Error"));
    }
  }

  downloadAndAddPlaylist(
      DownloadBookEvent event, Emitter<BookDetailedState> emit) async {
    if (await networkInfo.isConnected) {
      emit(state.copyWith(status: BookDetailedStatus.loading));
      try {
        DBHelper database = di();
        var book = event.book ?? Book();
        var audioBookUrl = book.audioUrl ?? '-';

        // Extract only the filename from the URL, ignoring any query parameters
        var uri = Uri.parse(audioBookUrl);
        var fileName =
            path.basename(uri.path); // Gets the filename, e.g., "sample3.mp3"

        // Split the filename into name and extension
        var nameWithoutExtension =
            path.basenameWithoutExtension(fileName); // "sample3"
        var extension = path.extension(fileName); // ".mp3"

        var directory = await getApplicationDocumentsDirectory();
        var now = DateTime.now();
        var time = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);

        // Create the new file path with date and time suffix
        var filePath = path.join(
            directory.path, "${nameWithoutExtension}_$time$extension");

        var responseImage = await dio.download(audioBookUrl, filePath);

        if (responseImage.statusCode == 200) {
          try {
            ///Change urlPath to the File
            final updatedBook = book.copyWith(audioUrl: filePath);

            ///Add model to local DB
            database.addToPlaylist(updatedBook);

            ///Add audio to the playlist
            pageManager.add(updatedBook.toMap());

            emit(state.copyWith(
                status: BookDetailedStatus.success, isDownloaded: true));
          } catch (e) {
            print(e);
            emit(state.copyWith(
                status: BookDetailedStatus.failure, message: "Error"));
          }
        } else {
          emit(state.copyWith(
              status: BookDetailedStatus.failure, message: "Error"));
        }
      } on DioException catch (e) {
        print(e);
        emit(state.copyWith(
            status: BookDetailedStatus.failure, message: "Error"));
      } catch (e) {
        print(e);
        emit(state.copyWith(
            status: BookDetailedStatus.failure, message: "Error"));
      }
    } else {
      emit(state.copyWith(
          status: BookDetailedStatus.noInternet, message: "No internet"));
    }
  }

  removeFileAndPlaylist(
      RemoveBookEvent event, Emitter<BookDetailedState> emit) async {
    emit(state.copyWith(status: BookDetailedStatus.loading));

    DBHelper database = di();
    var book = event.book ?? Book();
    var bookId = book.id ?? '-';

    ///Delete DB
    database.removeFromPlaylist(bookId);

    ///Delete file
    var dbBook = await database.getBookById(bookId);
    if (dbBook != null) {
      var filePath = dbBook.audioUrl ?? '-';
      deleteFileFromInternalStorage(filePath);
    }

    ///Remove from playlist
    pageManager.remove(book.toMap());

    emit(state.copyWith(
        status: BookDetailedStatus.success, isDownloaded: false));
  }
}
