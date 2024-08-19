part of 'books_home_bloc.dart';

abstract class BooksHomeEvent extends Equatable {
  const BooksHomeEvent();
}

class getBooksEvent extends BooksHomeEvent {
  @override
  List<Object?> get props => [];
}