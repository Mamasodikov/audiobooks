import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/core/network/network_info.dart';
import 'package:audiobooks/core/utils/functions.dart';
import 'package:audiobooks/features/home/data/datasources/home_local_datasource.dart';
import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:audiobooks/features/home/domain/usecases/u_book_detailed.dart';
import 'package:audiobooks/features/player/page_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'book_detailed_event.dart';

part 'book_detailed_state.dart';

/// Domain layer is not fully implemented yet for instant testing and possible changes of functions

class BookDetailedBloc extends Bloc<BookDetailedEvent, BookDetailedState> {
  final NetworkInfo networkInfo;
  final Dio dio;
  final PageManager pageManager;
  final UBookDetailedDownload uBookDetailedDownload;

  BookDetailedBloc(
      {required this.pageManager,
      required this.networkInfo,
      required this.dio,
      required this.uBookDetailedDownload})
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
      debugPrint(e.toString());
      emit(
          state.copyWith(status: BookDetailedStatus.failure, message: "Error"));
    }
  }

  downloadAndAddPlaylist(
      DownloadBookEvent event, Emitter<BookDetailedState> emit) async {
    if (await networkInfo.isConnected) {
      emit(state.copyWith(status: BookDetailedStatus.loading));

      var result = await uBookDetailedDownload(event);
      result.fold(
          (failure) => {
                emit(state.copyWith(
                    status: BookDetailedStatus.failure,
                    message: failure.errorMessage))
              },
          (r) => {
                emit(state.copyWith(
                    status: BookDetailedStatus.success, isDownloaded: r))
              });
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
