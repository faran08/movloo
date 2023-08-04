import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:movloo/MyHomePage.dart';
import 'package:movloo/splashPage.dart';
import 'package:movloo/webFiles/webHomePage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      FlutterStatusbarcolor.setStatusBarColor(Colors.white);
      return MaterialApp(
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        title: 'Loo On The Move',
        routes: {
          '/': (context) => const SplashPage(),
          '/home': (context) => const MyHomePage(title: 'Loo on the Move'),
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: const SplashPage(),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Loo On The Move - Admin Page',
        routes: {
          '/': (context) => const webHomePage(
                title: 'Loo on the Move - Admin Page',
              )
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      );
    }
  }
}
