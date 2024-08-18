import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di.dart' as di;
import 'feature/app.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await di.init();

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    ).then((val) {
      runApp(const AppProvider());
    });
  }, (error, stacktrace) {
    log('AudioBooks app error: $error');
  });
}
