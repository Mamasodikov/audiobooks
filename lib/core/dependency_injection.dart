import 'package:audio_service/audio_service.dart';
import 'package:audiobooks/features/home/data/datasources/home_local_datasource.dart';
import 'package:audiobooks/features/home/presentation/bloc/book_detailed/book_detailed_bloc.dart';
import 'package:audiobooks/features/home/presentation/bloc/books_home/books_home_bloc.dart';
import 'package:audiobooks/features/player/audio_handler.dart';
import 'package:audiobooks/features/player/page_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network/app_interceptor.dart';
import 'network/network_info.dart';

final di = GetIt.instance;

Future<void> init() async {
  debugPrint('=========== Dependency injection initializing.... ===========');

  /// Local cache

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  di.registerFactory(() => prefs);

  ///Database
  di.registerSingletonAsync<DBHelper>(() async {
    final dbHelper = DBHelper();
    await dbHelper.initDatabase(); // Ensure the database is initialized
    return dbHelper;
  });

  ///Audio services
  // services
  di.registerSingleton<AudioHandler>(await initAudioService());

  // page state
  di.registerLazySingleton<PageManager>( () => PageManager());
  await PageManager().init();

  ///Versioning
  // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // APP_VERSION = packageInfo.version;

  final Dio dio = Dio(BaseOptions(
    // baseUrl: 'baseUrl',
    connectTimeout: Duration(seconds: 60),
    receiveTimeout: Duration(seconds: 60),
  ));
  dio.interceptors.add(AppInterceptor());

  /// Network
  di.registerLazySingleton<Dio>(() => dio);

  /// Network Info
  di.registerLazySingleton(() => InternetConnectionChecker());
  di.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(di()));

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  di.registerLazySingleton(() => navigatorKey);

  ///BLOCK

  di.registerFactory(
    () => BooksHomeBloc(
      dio: di(),
      networkInfo: di(),
    ),
  );

  di.registerFactory(
        () => BookDetailedBloc(
      dio: di(),
      networkInfo: di(), pageManager: di(),
    ),
  );

  ///Repositories

  // di.registerLazySingleton<MainRepository>(() => MainRepositoryImpl(
  //     mainRemoteDataSourcesImpl: di(),
  //     mainLocalDataSourcesImpl: di(),
  //     networkInfo: di(),
  //     isarService: di()));

  ///Use Cases

  // di.registerLazySingleton(() => MainUsesCases(mainRepository: di()));

  ///Data sources
  // di.registerLazySingleton<TaskRemoteDatasource>(
  //         () => XXXRemoteDatasourceImpl(dio: di()));
  //
  // di.registerLazySingleton<TaskLocalDataSource>(
  //         () => XXXLocalDataSourceImpl(isarService: di()));

  debugPrint('=========== Dependency injection initializing finished ===========');
}
