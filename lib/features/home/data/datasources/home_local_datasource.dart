import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class HomeLocalDatasource {
  Future<dynamic> addToPlaylist();
  Future<dynamic> removeFromPlaylist();
  Future<dynamic> getPlaylist();
  Future<dynamic> getBookById();
}

class HomeLocalDatasourceImpl extends HomeLocalDatasource{
  @override
  Future addToPlaylist() {
    // TODO: implement addToPlaylist
    throw UnimplementedError();
  }

  @override
  Future getBookById() {
    // TODO: implement getBookById
    throw UnimplementedError();
  }

  @override
  Future getPlaylist() {
    // TODO: implement getPlaylist
    throw UnimplementedError();
  }

  @override
  Future removeFromPlaylist() {
    // TODO: implement removeFromPlaylist
    throw UnimplementedError();
  }
  
}

///DB Methods

class DBHelper {
  Database? _db;

  Future<Database> get db async {
    try {
      if (_db != null) {
        return _db!;
      }
      _db = await initDatabase();
      return _db!;
    } catch (e) {
      debugPrint('Error getting database: $e');
      rethrow; // Rethrow the exception if necessary
    }
  }

  Future<Database> initDatabase() async {
    try {
      return await openDatabase(
        join(await getDatabasesPath(), "audio_books.db"),
        onCreate: (db, version) async {
          try {
            await db.execute('''
              CREATE TABLE books(
              id TEXT PRIMARY KEY,
              audioUrl TEXT,
              imgUrl TEXT,
              title TEXT,
              author TEXT
              )
            ''');
          } catch (e) {
            debugPrint('Error creating table: $e');
          }
        },
        version: 1,
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> addToPlaylist(Book book) async {
    try {
      final dbClient = await db;
      await dbClient.insert(
        "books",
        book.toMap(),
        conflictAlgorithm:
        ConflictAlgorithm.replace, // Replace if the same id exists
      );
    } catch (e) {
      debugPrint('Error adding to playlist: $e');
    }
  }

  Future<void> removeFromPlaylist(String id) async {
    try {
      final dbClient = await db;
      await dbClient.delete(
        "books",
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error removing from playlist: $e');
    }
  }

  Future<List<Book>> getPlaylist() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query("books");

      return List.generate(maps.length, (i) {
        return Book(
            id: maps[i]['id'],
            title: maps[i]['title'],
            author: maps[i]['author'],
            audioUrl: maps[i]['audioUrl'],
            imgUrl: maps[i]['imgUrl']);
      });
    } catch (e) {
      debugPrint('Error getting playlist: $e');
      return [];
    }
  }

  Future<Book?> getBookById(String id) async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        "books",
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Book.fromMap(maps.first);
      } else {
        return null; // Return null if no book is found
      }
    } catch (e) {
      debugPrint('Error getting book by ID: $e');
      return null;
    }
  }
}