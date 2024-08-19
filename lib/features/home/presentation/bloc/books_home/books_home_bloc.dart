import 'dart:convert';

import 'package:audiobooks/core/network/network_info.dart';
import 'package:audiobooks/core/utils/constants.dart';
import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:audiobooks/features/home/data/models/category_model.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'books_home_event.dart';
part 'books_home_state.dart';

class BooksHomeBloc extends Bloc<BooksHomeEvent, BooksHomeState> {
  final NetworkInfo networkInfo;
  final Dio dio;

  BooksHomeBloc({required this.networkInfo, required this.dio})
      : super(BooksHomeState.initial()) {
    on<getBooksEvent>(loadBooks);
  }

  loadBooks(getBooksEvent event, Emitter<BooksHomeState> emit) async {

    if (await networkInfo.isConnected) {

      emit(state.copyWith(status: BooksHomeStatus.loading));
      try {
        var response = await dio.get(APIPath.getBooks);
        if (response.statusCode == 200) {
          try {
            final jsonResponse = jsonDecode(response.data) as List;

            print(jsonResponse);

            var categories = parseCategories(jsonResponse);

            emit(state.copyWith(status: BooksHomeStatus.success, categories: categories));
          } catch (e) {
            print(e);
            emit(state.copyWith(
                status: BooksHomeStatus.failure, message: "Error"));
          }
        } else {
          emit(state.copyWith(
              status: BooksHomeStatus.failure, message: "Error"));
        }
      } on DioException catch (e) {
        emit(state.copyWith(status: BooksHomeStatus.failure, message: "Error"));
      } catch (e) {
        emit(state.copyWith(status: BooksHomeStatus.failure, message: "Error"));
      }
    } else {

      emit(state.copyWith(
          status: BooksHomeStatus.noInternet,
          message: "No internet"));
    }
  }
}
