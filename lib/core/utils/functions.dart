import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audiobooks/core/helper/custom_toast.dart';
import 'package:audiobooks/core/utils/constants.dart';
import 'package:audiobooks/feature/home/data/datasources/home_local_datasource.dart';
import 'package:audiobooks/feature/home/data/models/book_model.dart';
import 'package:audiobooks/feature/player/page_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> deleteFileFromInternalStorage(String fileName,
    {bool withPath = true}) async {
  try {
    // Get the application documents directory
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

    // Create a file path
    String filePath;
    if (!withPath) {
      filePath = '${appDocumentsDirectory.path}/$fileName';
    } else {
      filePath = fileName;
    }

    // Check if the file exists before attempting to delete
    if (await File(filePath).exists()) {
      // Delete the file
      await File(filePath).delete(recursive: true);
      print('File deleted successfully: $filePath');
    } else {
      print('File not found: $filePath');
      // CustomToast.showToast('File not found: $filePath');
    }
  } catch (e) {
    print('Error deleting file: $e');
    CustomToast.showToast('Error deleting file: $e');
  }
}

bool isWebUrl(String path) {
  final urlPattern = r'^(http[s]?:\/\/|www\.)';
  final regExp = RegExp(urlPattern);

  return regExp.hasMatch(path);
}

bool isLocalFilePath(String path) {
  // Assuming that if it's not a web URL, it's a local file path
  return !isWebUrl(path);
}

Future<bool> deleteFromDBAndPlaylist(
    {required DBHelper database,
    required PageManager pageManager,
    required Book book}) async {
  var bookId = book.id ?? '-';

  try {
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
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> addToDBAndPlaylist(
    {required DBHelper database,
    required PageManager pageManager,
    required Book updatedBook}) async {
  try {
    ///Add model to local DB
    database.addToPlaylist(updatedBook);

    ///Add audio to the playlist
    pageManager.add(updatedBook.toMap());
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

MediaItem convertBookToMediaItem(Book book) {
  return MediaItem(
    id: book.id ?? '', // Use a default value if id is null
    title: book.title ?? '', // Use a default value if title is null
    extras: {
      'author': book.author ?? '',
      // Use a default value if author is null
      'audioUrl': book.audioUrl ?? '',
      // Use a default value if audioUrl is null
      'imgUrl': book.imgUrl ?? '',
      // Use a default value if imgUrl is null
    },
  );
}

Book convertMediaItemToBook(MediaItem mediaItem) {
  return Book(
    id: mediaItem.id,
    // Get the id from MediaItem
    audioUrl: mediaItem.extras?['audioUrl'],
    // Get the audioUrl from extras
    imgUrl: mediaItem.extras?['imgUrl'],
    // Get the imgUrl from extras
    title: mediaItem.title,
    // Get the title from MediaItem
    author: mediaItem.extras?['author'], // Get the author from extras
  );
}

Future<bool?> showAlertText(BuildContext context, String question) async {
  return await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: Text("Confirmation"),
          content: Text(question),
          actions: [
            // The "Yes" button
            CupertinoDialogAction(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop(true);
                },
                child: Text("Yes", style: TextStyle(color: cRedColor))),
            CupertinoDialogAction(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: cFirstColor),
                ))
          ],
        );
      });
}
