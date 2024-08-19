import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/dependency_injection.dart' as di;
import 'features/app.dart';

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
