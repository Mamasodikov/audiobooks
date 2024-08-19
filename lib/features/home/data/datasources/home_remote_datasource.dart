import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:audiobooks/features/player/page_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/dependency_injection.dart';
import 'home_local_datasource.dart';
import 'package:path/path.dart' as path;

abstract class HomeRemoteDatasource {
  Future<bool> downloadAndAddPlaylist(Book book);
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final Dio client;
  final DBHelper database;
  final PageManager pageManager;

  HomeRemoteDatasourceImpl(
      {required this.client,
      required this.database,
      required this.pageManager});

  @override
  Future<bool> downloadAndAddPlaylist(Book book) async {
    try {
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
      var filePath =
          path.join(directory.path, "${nameWithoutExtension}_$time$extension");

      var responseImage = await client.download(audioBookUrl, filePath);

      if (responseImage.statusCode == 200) {
        try {
          ///Change urlPath to the File path
          final updatedBook = book.copyWith(audioUrl: filePath);

          ///Add model to local DB
          database.addToPlaylist(updatedBook);

          ///Add audio to the playlist
          pageManager.add(updatedBook.toMap());

          return true;
        } catch (e) {
          debugPrint(e.toString());
          return false;
        }
      } else {
        return false;
      }
    } on DioException catch (e) {
      debugPrint(e.toString());
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
