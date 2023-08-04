import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movloo/MyHomePage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  "assets/OIG.jpeg",
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              DefaultTextStyle(
                style: GoogleFonts.pacifico(fontSize: 40),
                child: AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Loo On The Mov',
                      textStyle: const TextStyle(
                        fontSize: 20,
                      ),
                      colors: [Colors.yellow, Colors.red],
                      speed: const Duration(milliseconds: 500),
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
