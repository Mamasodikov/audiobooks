import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:dio/dio.dart';

abstract class HomeRemoteDatasource {
  Future<List<bool>> downloadAndAddPlaylist(Book book);
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final Dio client;

  HomeRemoteDatasourceImpl( {required this.client});

  @override
  Future<List<bool>> downloadAndAddPlaylist(Book book) {
    // TODO: implement downloadAndAddPlaylist
    throw UnimplementedError();
  }


}