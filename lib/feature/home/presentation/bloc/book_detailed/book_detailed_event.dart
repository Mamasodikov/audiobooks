part of 'book_detailed_bloc.dart';

abstract class BookDetailedEvent extends Equatable {
  const BookDetailedEvent();
}

class LoadBookEvent extends BookDetailedEvent {

  final Book? book;

  LoadBookEvent({required this.book});

  @override
  List<Object?> get props => [book];
}

class DownloadBookEvent extends BookDetailedEvent {

  final Book? book;

  DownloadBookEvent({required this.book});

  @override
  List<Object?> get props => [book];
}

class RemoveBookEvent extends BookDetailedEvent {

  final Book? book;

  RemoveBookEvent({required this.book});

  @override
  List<Object?> get props => [book];
}