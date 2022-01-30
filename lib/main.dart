import 'package:acela/src/screens/home_screen/home_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  Widget futureBuilder(Widget withWidget) {
    return FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Firebase not initialized');
          } else if (snapshot.hasData) {
            return withWidget;
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acela - 3Speak App',
      theme: ThemeData.dark(),
      routes: {
        VideoDetailsScreen.routeName: (context) =>
            futureBuilder(const VideoDetailsScreen()),
        '/': (context) => futureBuilder(const HomeScreen()),
      },
      // home: const HomeScreen(),
    );
  }
}
