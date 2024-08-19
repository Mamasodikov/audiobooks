part of 'books_home_bloc.dart';

enum BooksHomeStatus {
  initial,
  loading,
  failure,
  success,
  noInternet,
}

class BooksHomeState extends Equatable {
  final BooksHomeStatus status;
  final String? message;
  final List<Category>? categories;
  final List<Book>? books;

  BooksHomeState({
    required this.status,
    this.message,
    this.categories,
    this.books,
  });

  static BooksHomeState initial() => BooksHomeState(
        status: BooksHomeStatus.initial,
      );

  BooksHomeState copyWith(
          {BooksHomeStatus? status,
          String? message,
          List<Category>? categories,
          List<Book>? books}) =>
      BooksHomeState(
          status: status ?? this.status,
          message: message ?? this.message,
          categories: categories ?? this.categories,
          books: books ?? this.books);

  @override
  List<Object?> get props => [status, message, categories, books];
}
