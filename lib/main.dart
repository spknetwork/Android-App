import 'package:acela/src/screens/home_screen/home_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acela - 3Speak App',
      theme: ThemeData.dark(),
      routes: {
        VideoDetailsScreen.routeName: (context) => const VideoDetailsScreen(),
        '/': (context) => const HomeScreen(),
      },
      // home: const HomeScreen(),
    );
  }
}