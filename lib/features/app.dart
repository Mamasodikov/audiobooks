import 'package:audiobooks/core/dependency_injection.dart';
import 'package:audiobooks/features/home/presentation/pages/books_home.dart';
import 'package:flutter/material.dart';

import 'player/page_manager.dart';

class AppProvider extends StatefulWidget {
  const AppProvider({super.key});

  @override
  State<AppProvider> createState() => _AppProviderState();
}

class _AppProviderState extends State<AppProvider> {
  PageManager pageManager = di();

  @override
  void initState() {
    pageManager.init();
    super.initState();
  }

  @override
  void dispose() {
    pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioBooks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      home: BooksHomePage.screen(),
    );
  }
}
