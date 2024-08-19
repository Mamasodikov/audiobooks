import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/core/network/network_info.dart';
import 'package:audiobooks/features/home/data/datasources/home_local_datasource.dart';
import 'package:audiobooks/features/home/data/datasources/home_remote_datasource.dart';
import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:audiobooks/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class HomeRepositoryImpl extends HomeRepository {
  final HomeRemoteDatasourceImpl homeRemoteDatasourceImpl;
  final HomeLocalDatasourceImpl homeLocalDatasourceImpl;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl(
      {required this.homeRemoteDatasourceImpl,
        required this.homeLocalDatasourceImpl,
        required this.networkInfo});

  @override
  Future<Either<Failure, bool>> downloadAndAddPlaylist(Book? book) {
    // TODO: implement downloadAndAddPlaylist
    throw UnimplementedError();
  }
}