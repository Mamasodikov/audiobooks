part of 'book_detailed_bloc.dart';

enum BookDetailedStatus {
  initial,
  loading,
  failure,
  success,
  noInternet,
}

class BookDetailedState extends Equatable {
  final BookDetailedStatus status;
  final String? message;
  final bool isDownloaded;
  final Book? localBook;

  BookDetailedState({
    required this.status,
    this.message,
    required this.isDownloaded,
    this.localBook,
  });

  static BookDetailedState initial() => BookDetailedState(
        status: BookDetailedStatus.initial,
        isDownloaded: false,
      );

  BookDetailedState copyWith(
          {BookDetailedStatus? status,
          String? message,
          bool? isDownloaded,
          Book? localBook}) =>
      BookDetailedState(
          status: status ?? this.status,
          message: message ?? this.message,
          isDownloaded: isDownloaded ?? this.isDownloaded,
          localBook: localBook ?? this.localBook);

  @override
  List<Object?> get props => [status, message, isDownloaded, localBook];
}
