import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  //Book detailed page
  Future<Either<Failure, bool>> downloadAndAddPlaylist(Book? book);
}